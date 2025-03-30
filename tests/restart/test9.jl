include("common.jl")

struct OutsideHandlingException <: Exception end;

handling(DivisionByZero => (x) -> if available_restart(:return_zero)
    invoke_restart(:return_zero)
end) do
    println(with_restart(:return_zero => () -> 0) do
        handling(OutsideHandlingException => (c) -> println("I am not supposed to see a OutsideHandlingException")) do
            error(DivisionByZero())
        end
    end)
    error(OutsideHandlingException())
end
