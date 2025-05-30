include("./common.jl")

struct TestException <: Exception end

handling(TestException => (c) -> invoke_restart(:return_value, 10), DivisionByZero => (c) -> invoke_restart(:return_value, 5)) do
    println(with_restart(:return_zero => () -> 0,
        :return_value => identity,
        :retry_using => reciprocal) do
        error(DivisionByZero())
    end)
end