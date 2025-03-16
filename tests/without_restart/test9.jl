include("./common.jl")

println(
    to_escape() do exit
        handling(DivisionByZero =>
            (c) -> (println("I saw it too"); exit("Done"))) do
            handling(DivisionByZero =>
                (c) -> println("I saw a division by zero")) do
                print(reciprocal(0))
            end
        end
    end
)