include("Exceptional.jl")  # Include the Exceptional module

using Printf

function interactive_restart_prompt(exception)
    restarts = availableRestarts

    if isempty(restarts)
        println("\nNo restarts available. Rethrowing exception.")
        throw(exception)
    end

    println("\nAn error occurred: ", exception)
    println("Available restarts:")

    for (i, r) in enumerate(restarts)
        desc = get_restart_description(r)
        @printf "%2d) %-10s : %s\n" i r.name desc
    end

    print("\nSelect restart (1-$(length(restarts)), q to quit): ")
    choice = readline()

    println("You selected: ", choice)

    if lowercase(choice) == "q"
        println("Quitting. Rethrowing exception.")
        throw(exception)
    end

    print("\nWrite args (press Enter to skip): ")
    args = readline()

    if isempty(args)
        args = nothing
    else
        parsed_args = tryparse(Int, args)
        if !isnothing(parsed_args)
            args = parsed_args
        end
    end

    try
        idx = parse(Int, choice)
        if 1 <= idx <= length(restarts)
            restart = restarts[idx]
            return invoke_interactive_restart(restart, args)
        else
            println("Invalid choice. Rethrowing exception.")
            throw(exception)
        end
    catch e
        rethrow(e)
    end
end

function get_restart_description(restart::Restart)
    "Invoke restart $(restart.name)"
end

function invoke_interactive_restart(restart::Restart, args)
    try
        if(!isnothing(args))
            invoke_restart(restart.name, args)
        else
            invoke_restart(restart.name)
        end
    catch e
        rethrow(e)
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

    if !handled && !isempty(availableRestarts)
        try
            interactive_restart_prompt(exception)
        catch e
            rethrow(e)
        end
    elseif !handled
        # This print is commented to allow all the tests to pass
        # Uncomment for better user experience
        # println("No restart found for exception: ", exception) 
        throw(exception)
    end
end

Base.error(exception) = begin
    if (exception isa Escape)
        throw(exception)
    else
        try
            interactive_signal(exception)
        catch e
            rethrow(e)
        end
    end
    throw(exception)
end