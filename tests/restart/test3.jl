include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:retry_using, 10)) do
    print(reciprocal(0))
end

