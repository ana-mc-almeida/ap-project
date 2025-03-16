include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:retry_using, 10)) do
    println(infinity())
end
