struct DivisionByZero <: Exception end
struct Escape{T} <: Exception 
    funcName::String
    result::T
end

reciprocal(x) = x == 0 ? throw(DivisionByZero()) : 1 / x

function handling(func, handlers...) # func não pode ter argumentos
    try
        return func()
    catch e
        for handler in handlers
            if e isa handler.first
                handler.second(e)
            end
        end
        rethrow(e)
    end
end

# Handling tests

handling(DivisionByZero => (c)->println("I saw a division by zero")) do
    reciprocal(0)
end

handling(DivisionByZero => (c)->println("I saw it too")) do
    handling(DivisionByZero => (c)->println("I saw a division by zero")) do
        reciprocal(0)
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
    
    escape_func = function(arg)
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

outer(n) = n

mystery(n) =
    1 +
    to_escape() do outer
        1 +
        to_escape() do inner
            1 +
            if n == 0
                inner(1)
            elseif n == 1
                outer(1)
            else
                1
            end
        end
    end

mystery(2)