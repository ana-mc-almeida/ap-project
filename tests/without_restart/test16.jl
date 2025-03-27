include("./common.jl")

# this test checks if the most 'specific' handler is chosen
# most 'specific' aka the first handler that matches the exception type

handling(ArithmeticException => (c) -> println("Arithmetic"),
    DivisionByZero => (c) -> println("DivisionByZero")) do
    handling(DivisionByZero => (c) -> println("DivisionByZero"),
        ArithmeticException => (c) -> println("Arithmetic")) do
        print(reciprocal(0))
    end
end
