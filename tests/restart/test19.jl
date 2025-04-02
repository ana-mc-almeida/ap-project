include("common.jl")

# Test if only the restarts from the current with_restart are removed from availableRestarts vector

handling(DivisionByZero => (x) -> invoke_restart(:return_one)) do
    println(
        with_restart(:return_zero => () -> 0, :return_one => () -> 1) do
            with_restart(:return_one => () -> 1) do
                error(DivisionByZero())
            end

            error(DivisionByZero())
        end
    )
end
