include("./common.jl")

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
        :return_value => identity,
        :retry_using => reciprocal) do
        value == 0 ?
        throw(DivisionByZero()) :
        1 / value
    end + 1

handling(DivisionByZero => (c) -> invoke_restart(:return_zero)) do
    println(reciprocal(0))
end