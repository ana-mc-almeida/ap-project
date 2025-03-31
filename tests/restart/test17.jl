include("common.jl")

handling(DivisionByZero => (x) ->
    if available_restart(:return_zero)
        invoke_restart(:return_zero)
    end
) do
    result = 0
    println(with_restart(:return_zero => () -> 0) do
        with_restart(:return_zero => () -> 0) do
            result += 1
        end
        result += 1
    end)
end
