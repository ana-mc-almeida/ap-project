include("./common.jl")

handling(DivisionByZero => (c) -> invoke_restart(:just_do_it)) do
    println(infinity())
end
