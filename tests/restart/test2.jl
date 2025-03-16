include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:return_value, 123)) do
    print(reciprocal(0))
end

