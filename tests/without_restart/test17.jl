include("./common.jl")

func(x) = x * 2

func2() = func(3)

teste() = 1 + to_escape() do func
    func2()
end

println(teste())
