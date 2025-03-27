include("common.jl")

to_escape() do exit
    handling(LineEndLimit => (c) -> exit()) do
        print_line("Hi, everybody! How are you feeling today?")
    end
end