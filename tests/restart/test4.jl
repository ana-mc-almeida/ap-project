include("./common.jl")

handling(DivisionByZero =>
    (c) -> for restart in (:return_one, :return_zero, :die_horribly)
        if available_restart(restart)
            invoke_restart(restart)
        end
    end) do
    print(reciprocal(0))
end
