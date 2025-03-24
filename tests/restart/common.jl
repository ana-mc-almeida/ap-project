include("../../Exceptional.jl")

reciprocal(value) =
    with_restart(:return_zero => () -> 0,
                 :return_value => identity,
                 :retry_using => reciprocal) do
        value == 0 ?
            throw(DivisionByZero()) :
            1 / value
    end

infinity() =
    with_restart(:just_do_it => () -> 1 / 0) do
        reciprocal(0)
    end