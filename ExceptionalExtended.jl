include("Exceptional.jl")

using Printf

function interactive_restart_prompt(exception)
    restarts = keys(availableRestarts)

    if isempty(restarts)
        # This print is commented to allow all the tests to pass
        # Uncomment for better user experience
        # println("\nNo restarts available. Rethrowing exception.")
        throw(exception)
    end

    println("\nAn error occurred: ", exception)
    println("Available restarts:")

    for (i, r) in enumerate(restarts)
        @printf "%2d) %-10s\n" i r
    end

    print("\nSelect restart (1-$(length(restarts)), q to quit): ")
    choice = readline()
    println("You selected: ", choice)

    if lowercase(choice) == "q"
        println("Quitting. Rethrowing exception.")
        throw(exception)
    end

    idx = parse(Int, choice)
    if 1 <= idx <= length(restarts)
        print("Write args (press Enter to skip): ")
        args = readline()
        parsed_args = tryparse(Int, args)
        if !isnothing(parsed_args)
            args = parsed_args
        end

        restart = collect(restarts)[idx]
        return invoke_restart(restart, args...)
    else
        println("Invalid choice. Rethrowing exception.")
        throw(exception)
    end
end

function interactive_signal(exception)
    global currentHandlers
    handled = false

    for handlerList in reverse(currentHandlers)
        for handler in handlerList
            if exception isa handler.first
                handler.second(exception)
                handled = true
                break
            end
        end
    end

    if !handled
        interactive_restart_prompt(exception)
    end
end

Base.error(exception) = begin
    interactive_signal(exception)
    throw(exception)
end