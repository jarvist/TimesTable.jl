# TimeTable.jl
# generates a set of randomised times-table questions of given factors (f), but
# stochastically includes the commutative pair (i.e. c × f = f × c) and the 'division fact'
# (c × f = a, then ask a ÷ f) in the next few questions.

using Random

@kwdef struct Question
    text::String
    answer::Int
end

Base.show(io::IO, q::Question) = print(io, q.text, " = ")

function practice(factors, n=10; show_answers=false, bank_threshold=5)
    # ALL times table combinations
    combo_pool = [(f, c) for f in factors for c in 1:12] |> shuffle
    
    question_bank = Question[]
    output_questions = Question[]
    
    for _ in 1:n
        # Refill bank if below threshold
        if length(question_bank) < bank_threshold
            
            refill_size = rand(bank_threshold:bank_threshold+6) # sometimes overfill bank, reducing correlation in questons

            while length(question_bank) < refill_size && !isempty(combo_pool)
                # factor (the '2 times table'), cofactor (1:12)
                f, c = pop!(combo_pool) 
                result = f * c
                # Compose 3 questions: both commutative multiplications & one division
                push!(question_bank, Question(text="$f × $c", answer=result))
                push!(question_bank, Question(text="$c × $f", answer=result))
                
                push!(question_bank, Question(text="$result ÷ $f", answer=c))
            end

            shuffle!(question_bank) # randomise order, for popping
        end
        
        # Pop random question from bank
        if !isempty(question_bank)
            push!(output_questions, pop!(question_bank))
            # FIXME: doesn't currently check for duplication
        else # if no questions left... we've finished all possibilities, so let's start again
            combo_pool = [(f, c) for f in factors for c in 1:12] |> shuffle
        end
    end
    
    # Print questions to stdout
    println("Generating $n times-table and division questions; factors $(join(factors, ", ")).\n")
    
    if show_answers
        for (i, q) in enumerate(output_questions)
            println("Q$i: $q")
        end
        println()
        for (i, q) in enumerate(output_questions)
            println("A$i: $(q.answer)")
        end
    else 
        for q in output_questions
            println(q)
        end
    end
end

# Example usage
function main()
    practice([2, 10], 200)
#    practice([3, 4], 6)
#    practice([7, 8, 9], 8)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

