module ExceptionalExtended

include("Exceptional.jl")  # Include the Exceptional module
using .Exceptional
println(names(Exceptional))  # Verifique se with_restart aparece na lista

# export to_escape, handling, with_restart, available_restart, invoke_restart, signal
export Exceptional

using Printf

# export @interactive, interactive_handler

# Handler interativo padrão
# const interactive_handler = e -> interactive_restart_prompt(e)

# """
#     @interactive expr

# Macro que executa a expressão com tratamento interativo automático de erros.
# """
# macro interactive(expr)
#     quote
#         try
#             handling(() -> $(esc(expr)),
#                 Exception => interactive_handler)
#         catch e
#             if !isempty(Exceptional.availableRestarts)
#                 interactive_restart_prompt(e)
#             else
#                 throw(e)
#             end
#         end
#     end
# end

"""
    interactive_restart_prompt(exception)

Mostra os restarts disponíveis ao usuário e permite que ele escolha um interativamente.
"""
function interactive_restart_prompt(exception)
    restarts = Exceptional.availableRestarts

    if isempty(restarts)
        println("\nNo restarts available. Rethrowing exception.")
        throw(exception)  # Usamos throw em vez de rethrow
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

    try
        idx = parse(Int, choice)
        if 1 <= idx <= length(restarts)
            restart = restarts[idx]
            return invoke_interactive_restart(restart)
        else
            println("Invalid choice. Rethrowing exception.")
            throw(exception)
        end
    catch
        println("Invalid input. Rethrowing exception.")
        throw(exception)
    end
end

"""
    get_restart_description(restart::Restart) -> String
"""
function get_restart_description(restart::Exceptional.Restart)
    "Invoke restart $(restart.name)"
end

"""
    invoke_interactive_restart(restart::Restart)
"""
function invoke_interactive_restart(restart::Exceptional.Restart)
    println("\nInvoking restart: $(restart.name)")
    println("Available Restart:", Exceptional.available_restart(restart.name))
    try
        Exceptional.invoke_restart(restart.name)
    catch e
        println("Failed to invoke restart: ", e)
        throw(e)
    end
end

"""
    interactive_signal(exception)

Função principal que decide como lidar com exceções de forma interativa.
"""
function interactive_signal(exception)
    handled = false
    for handlerList in reverse(Exceptional.currentHandlers)
        for handler in handlerList
            if exception isa handler.first
                handler.second(exception)
                handled = true
                break
            end
        end
        handled && break
    end


    # Se não foi tratado e há restarts disponíveis, mostra prompt
    if !handled && !isempty(Exceptional.availableRestarts)
        interactive_restart_prompt(exception)
    elseif !handled
        throw(exception)
    end
end


Base.error(exception) = begin
    # Exceptional.signal(exception)
    if (exception isa Exceptional.Escape)
        # println("Escape exception: ", exception)
    else
        interactive_signal(exception)
    end
    throw(exception)
end


end