include("common.jl")

handling(DivisionByZero => (x) -> if available_restart(:return_zero)
    invoke_restart(:return_zero)
end) do
    handling(DivisionByZero =>
        (c) -> println("I saw a division by zero")) do
        println(with_restart(:return_zero => () -> 0) do
            reciprocal(0)
        end)
        println(with_restart(:return_zero => () -> 0) do
            reciprocal(0)
        end)
    end
    println(with_restart(:return_zero => () -> 0) do
        reciprocal(0)
    end)
end
