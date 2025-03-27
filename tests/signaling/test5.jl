include("common.jl")

handling(LineEndLimit => (c) -> println()) do
    print_line("Hi, everybody! How are you feeling today?")
end