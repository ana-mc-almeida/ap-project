include("../../Exceptional.jl")

reciprocal(x) = x == 0 ? throw(DivisionByZero()) : 1 / x

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