struct Escape{T} <: Exception
    funcName::String
    result::T
end

struct UnavailableRestart{T} <: Exception
    restart::Symbol
    args::T
end

######################### to_escape #########################

function to_escape(func)
    methods = collect(Base.methods(func))
    escapeName = string(method_argnames(last(methods))[2])

    escape_func = function (args...)
        error(Escape(escapeName, args))
    end

    try
        return func(escape_func)
    catch e
        if e isa Escape && e.funcName == escapeName
            return length(e.result) == 1 ? e.result[1] : e.result
        else
            rethrow()
        end
    end
end

function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[1:m.nargs]
end

######################### handling #########################

currentHandlers = Vector{Vector{Pair{DataType, Function}}}()

function handling(func, handlers...) # func não pode ter argumentos
    handlersList = Vector{Pair{DataType, Function}}()
    for handler in handlers
        push!(handlersList, handler)
    end

    global currentHandlers
    push!(currentHandlers, handlersList)

    res = func()

    pop!(currentHandlers)

    return res
end

######################### restarts #########################

availableRestarts = Dict{Symbol, Int}()

function with_restart(func, restarts...)
    global availableRestarts
    for restart in restarts
        availableRestarts[restart.first] = get(availableRestarts, restart.first, 0) + 1
    end

    handlersLength = length(currentHandlers)

    try
        return func()
    catch e
        if e isa UnavailableRestart
            for restart in restarts
                if restart.first == e.restart
                    return restart.second(e.args...)
                end
            end
        end
        rethrow()
    finally
        for restart in restarts
            availableRestarts[restart.first] > 1 ?
                availableRestarts[restart.first] -= 1 :
                delete!(availableRestarts, restart.first)
        end

        while length(currentHandlers) != handlersLength
            pop!(currentHandlers)
        end
    end
end

function available_restart(name::Symbol)
    return get(availableRestarts, name, 0) >= 1
end

function invoke_restart(restart::Symbol, args...)
    throw(UnavailableRestart(restart, args))
end

##################### raising exception #####################

function signal(exception)
    global currentHandlers

    for handlerList in reverse(currentHandlers)
        for handler in handlerList
            if exception isa handler.first
                handler.second(exception)
                break
            end
        end
    end
end

Base.error(exception) = begin
    signal(exception)
    throw(exception)
end