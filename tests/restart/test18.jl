include("common.jl")

handling(DivisionByZero => (x) -> 
    if available_restart(:return_zero)
        invoke_restart(:return_zero)
    end
) do
    println(with_restart(:return_zero => () -> 0) do
        1 + 1
    end)
    error(DivisionByZero())
end
