include("../../Exceptional2.jl")

abstract type ArithmeticException <: Exception end
struct DivisionByZero <: ArithmeticException end

reciprocal(x) = x == 0 ? error(DivisionByZero()) : 1 / x

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

struct Error1 <: Exception end
struct Error2 <: Exception end
struct Error3 <: Exception end
struct Error4 <: Exception end

raise_error(x) = begin
    if (x == 1)
        error(Error1())
    end
    if (x == 2)
        error(Error2())
    end
    if (x == 3)
        error(Error3())
    end
    error(Error4())
end
