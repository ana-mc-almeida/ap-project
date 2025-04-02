include("common.jl")

# Test if outer with_restart returns to the right place after an error is found in inner with_restart 

handling(DivisionByZero => (x) -> invoke_restart(:return_one)) do
    println(
        with_restart(:return_one => () -> 1) do
            with_restart(:return_zero => () -> 0) do
                error(DivisionByZero())
            end + 3
        end
    )
end
