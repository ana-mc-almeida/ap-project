include("../../Exceptional2.jl")


struct LineEndLimit <: Exception
end
print_line(str, line_end=20) =
    let col = 0
        for c in str
            print(c)
            col += 1
            if col == line_end
                signal(LineEndLimit())
                col = 0
            end
        end
    end