struct DivisionByZero <: Exception end
struct Escape{T} <: Exception
    funcName::String
    result::T
end

const RESTARTS_STACK = Dict{Symbol,Function}()
INVOKED_RESTART = nothing

function handling(func, handlers...) # func não pode ter argumentosº
    global INVOKED_RESTART

    while true
        try
            return func()
        catch e
            for handler in handlers
                if e isa handler.first
                    handler.second(e)
                end
            end

            if !isnothing(INVOKED_RESTART)
                continue
            else
                rethrow(e)
                return
            end
        end
    end
end

function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[1:m.nargs]
end

function to_escape(func) # a função func tem de ter um argumento exatamente. E quando esse argumento for chamado durante a execução de func, só pode ter um argumento também
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
    global INVOKED_RESTART

    for restart in restarts
        RESTARTS_STACK[restart.first] = restart.second
    end

    if !isnothing(INVOKED_RESTART) && available_restart(INVOKED_RESTART.first)
        res = INVOKED_RESTART.second
        INVOKED_RESTART = nothing
        return res
    else
        return func()
    end

    for restart in restarts
        delete!(RESTARTS_STACK, restart.name)
    end
end

function available_restart(name::Symbol)
    return haskey(RESTARTS_STACK, name)
end

function invoke_restart(name::Symbol, args...)
    global INVOKED_RESTART

    if available_restart(name)
        INVOKED_RESTART = name => RESTARTS_STACK[name](args...)
    end
end

