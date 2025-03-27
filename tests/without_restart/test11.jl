include("./common.jl")

handling(Error1 => (e) -> println("Error1"), Error2 => (e) -> println("Error2")) do
    handling(Error3 => (e) -> println("Error3"), Error4 => (e) -> println("Error4")) do
        raise_error(1)
    end
end

