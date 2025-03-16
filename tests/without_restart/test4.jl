
include("./common.jl")

handling(() -> print(reciprocal(0)),
    DivisionByZero => (c) -> println("I saw a division by zero"))