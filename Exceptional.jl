struct Escape{T} <: Exception
    funcName::String
    result::T
end
struct InvokeRestart{T} <: Exception
    funcName::Symbol
    args::T
end

currentHandlers = Vector{Pair{DataType, Function}}()
availableRestarts = Dict{Symbol, Int}()

function handling(func, handlers...) # func não pode ter argumentos
    global currentHandlers
    for handler in handlers
        push!(currentHandlers, handler)
    end

    handlersLen = length(handlers)

    handlersToCheck = handlersLen == 0 ? currentHandlers : currentHandlers[end-handlersLen+1:end]

    try
        return func()
    catch e
        for handler in reverse(handlersToCheck)
            if e isa handler.first
                handler.second(e)
                break
            end
        end
        rethrow(e)
    finally
        for _ in handlers
            pop!(currentHandlers)
        end
    end
end

function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[1:m.nargs]
end

function to_escape(func) # Quando o argumento for chamado como função durante a execução de func, só pode ter um argumento
    methods = collect(Base.methods(func))
    escapeName = string(method_argnames(last(methods))[2])

    escape_func = function (arg)
        throw(Escape(escapeName, arg))
    end

    try
        return func(escape_func)
    catch e
        if e isa Escape && e.funcName == escapeName
            return e.result
        else
            rethrow(e)
        end
    end

end

function with_restart(func, restarts...)
    global availableRestarts
    for restart in restarts
        availableRestarts[restart.first] = get(availableRestarts, restart.first, 0) + 1
    end

    try
        return handling(func)
    catch e
        if e isa InvokeRestart
            for restart in restarts
                if e.funcName == restart.first
                    return restart.second(e.args...)
                end
            end
        end
        rethrow(e)
    finally
        for restart in restarts
            availableRestarts[restart.first] > 1 ?
            availableRestarts[restart.first] -= 1 :
            delete!(availableRestarts, restart.first)
        end
    end
end

function available_restart(name::Symbol)
    return get(availableRestarts, name, 0) >= 1
end

function invoke_restart(name::Symbol, args...)
    throw(InvokeRestart(name, args))
end
