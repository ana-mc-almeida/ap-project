include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:return_value, 10)) do
    handling(DivisionByZero => (c) -> invoke_restart(:return_value, 5)) do
        println(with_restart(:return_zero => () -> 0,
            :return_value => identity,
            :retry_using => reciprocal) do
            throw(DivisionByZero())
        end)
    end
end