# TimesTable.jl
# Generates a set of randomised arithmetic questions for any operation (+, -, ×, ÷).
# Stochastically includes commutative pairs (e.g., a × b = b × a) and inverse operations
# (e.g., a × b = c, then ask c ÷ a) in the next few questions.

using Random

# Unicode operator display and inverse operation mappings
const UNICODE_OPS = Dict{Symbol, String}(:+ => "+", :- => "−", :* => "×", :÷ => "÷")
const INVERSE_OPS = Dict{Symbol, Symbol}(:+ => :-, :- => :+, :* => :÷, :÷ => :*)

expr_to_unicode(ex::Expr) = let (op, args...) = ex.args; join(args, " $(get(UNICODE_OPS, op, string(op))) ") end

@kwdef struct Question
    expr::Expr
    answer::Number
end

Base.show(io::IO, q::Question) = print(io, expr_to_unicode(q.expr), " = ")

function generate_question_set(op::Symbol, a, b, inverseoperations::Bool)
    result = eval(Expr(:call, op, a, b))
    
    # Primary question
    questions = [Question(expr=Expr(:call, op, a, b), answer=result)]
    # commutative pair
    op in (:+, :*) && push!(questions, Question(expr=Expr(:call, op, b, a), answer=result))
    # inverse operation
    if inverseoperations
        inv_op = INVERSE_OPS[op]
        append!(questions, Question(expr=Expr(:call, inv_op, result, a), answer=b))
    end
    return questions
end

function practice(factors, n=10; op::Symbol=:*, minval=1, maxval=12, show_answers=false, inverseoperations=true, bank_threshold=5)
    println("Generating $n $(get(UNICODE_OPS, op, string(op))) questions; factors $(join(factors, ", ")), range $minval:$maxval. Inverse operations: $inverseoperations.\n")
    
    # All value×range combinations, shuffled for randomness
    combo_pool = [(f, c) for f in factors for c in minval:maxval] |> shuffle
    question_bank, output_questions = Question[], Question[]
    
    for _ in 1:n
        # Refill bank if below threshold (sometimes overfill to reduce correlation)
        if length(question_bank) < bank_threshold
            refill_size = rand(bank_threshold:bank_threshold+6)
            while length(question_bank) < refill_size 
                if isempty(combo_pool) # once we've asked all questions... start again! 
                    combo_pool = [(f, c) for f in factors for c in minval:maxval] |> shuffle
                end
                v, c = pop!(combo_pool)
                append!(question_bank, generate_question_set(op, v, c, inverseoperations))
            end
            shuffle!(question_bank)
        end
        
        !isempty(question_bank) && push!(output_questions, pop!(question_bank))
    end
    
    # Print questions (optionally with separated answers)
    if show_answers
        foreach(((i, q),) -> println("Q$i: $q"), enumerate(output_questions))
        println()
        foreach(((i, q),) -> println("A$i: $(q.answer)"), enumerate(output_questions))
    else 
        foreach(println, output_questions)
    end
end

function main()
#    practice([2, 5, 10], 20; op=:*, minval=1, maxval=12)              # Times tables with division
    practice(1:5, 100; op=:+, minval=0, maxval=5, inverseoperations=false)   # Number bonds (addition/subtraction)
    # practice([3, 4, 7], 30; op=:*, minval=1, maxval=12)             # More difficult times tables
    # practice([2, 5, 10], 20; op=:*, inverseoperations=false)        # Multiplication only (no division)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

