include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:return_value, 1)) do
    println(infinity())
end
