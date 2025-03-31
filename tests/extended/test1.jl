include("../../ExceptionalExtended.jl")
using .ExceptionalExtended

struct DivisionByZero <: Exception end

reciprocal(value) =
    Exceptional.with_restart(:return_zero => () -> 0,
        :return_value => identity,
        :retry_using => reciprocal) do

        # println("Available restart :return_zero: ",Exceptional.available_restart(:return_zero))
        # Exceptional.invoke_restart(:return_zero)

        value == 0 ?
        Exceptional.error(DivisionByZero()) :
        1 / value
    end

# Exceptional.handling(DivisionByZero => (c) -> Exceptional.invoke_restart(:return_zero)) do
    println(reciprocal(0))
# end