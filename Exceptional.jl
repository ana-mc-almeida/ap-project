module Exceptional

struct Escape{T} <: Exception
    funcName::String
    result::T
end

struct UnavailableRestart{T} <: Exception
    restart::Symbol
    args::T
end

struct Restart
    name::Symbol
    func::Function
    escape::Function
end

function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[1:m.nargs]
end

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

availableRestarts = Vector{Restart}()

function with_restart(func, restarts...)
    global availableRestarts

    handlersLength = length(currentHandlers)

    ret = to_escape() do escape
        for restart in restarts
            push!(availableRestarts, Restart(restart.first, restart.second, escape))
        end
     
        return func()
    end

    for _ in restarts
        pop!(availableRestarts)
    end

    while length(currentHandlers) != handlersLength
        pop!(currentHandlers)
    end

    return ret
end

function available_restart(name::Symbol)
    global availableRestarts
    
    for restart in availableRestarts
        if restart.name == name
            return true
        end
    end

    return false
end

function invoke_restart(name::Symbol, args...)
    for restart in reverse(availableRestarts)
        if restart.name == name
            restart.escape(restart.func(args...))
            return
        end
    end

    throw(UnavailableRestart(restart, args))
end

function signal(exception) # TODO explodir se o arg não for exception?
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

end