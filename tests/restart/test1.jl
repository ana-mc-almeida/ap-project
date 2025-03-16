include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:return_zero)) do
    println(reciprocal(0))
end