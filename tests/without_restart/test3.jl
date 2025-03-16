
include("./common.jl")

handling(DivisionByZero =>
    (c) -> println("I saw a division by zero")) do
    print(reciprocal(0))
end