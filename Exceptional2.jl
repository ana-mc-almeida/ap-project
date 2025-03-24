struct DivisionByZero <: Exception end
struct Escape{T} <: Exception
    funcName::String
    result::T
end
struct InvokeRestart{T} <: Exception
    funcName::Symbol
    args::T
end

currentHandlers = Vector{Pair{DataType, Function}}()
#availableRestarts = # Map<String, Integer>

function handling(func, handlers...) # func não pode ter argumentos
    global currentHandlers
    if (!isnothing(handlers[1])) # TODO permitir mais do que 1 handler
        push!(currentHandlers, handlers[1])
    end

    try
        return func()
    catch e
        for handler in currentHandlers
            if e isa handler.first
                handler.second(e)
                # TODO É para dar break aqui? Ou devemos olhar para todos os handlers que tratem da mesma exceção?
            end
        end
        rethrow(e)
    finally
        if !isnothing(handlers[1])
            for _ in handlers
                pop!(currentHandlers)
            end
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
    # Guardar restarts

    try 
        return handling(func, nothing)
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
        # Apaga restarts
    end
end

function available_restart(name::Symbol)
    return true
end

function invoke_restart(name::Symbol, args...)
    throw(InvokeRestart(name, args))
end

# Simple test

handling(DivisionByZero => (c)->invoke_restart(:retry_using, 10)) do
    reciprocal(0)
end

reciprocal(value) =
    with_restart(:return_zero => ()->0,
                 :return_value => identity,
                 :retry_using => reciprocal) do
        value == 0 ?
            throw(DivisionByZero()) :
            1/value
    end