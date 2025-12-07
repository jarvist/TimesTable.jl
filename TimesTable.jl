# TimesTable.jl (- now quite misnamed!)
# Generates a set of randomised arithmetic questions for a given operation (currently +, -, ×, ÷).
# Stochastically includes commutative pairs (e.g., a × b = b × a) and inverse operations
# (e.g., a × b = c, then ask c ÷ a) in the next few questions.
# Also generates 'fill in the blank' questions

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
        push!(questions, Question(expr=Expr(:call, inv_op, result, a), answer=b))
    end
    return questions
end

function practice(factors, n=10; op::Symbol=:*, minval=1, maxval=12, fill_in_the_blank=false, inverseoperations=true, bank_threshold=5)
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
    if fill_in_the_blank
        for o in output_questions
            l = expr_to_unicode(o.expr) * " = " * string(o.answer)
            parts = split(l, " ")  # ["3", "+", "5", "=", "8"]
            parts[rand([1,2,3,5])] = "___" # randomly hide a field, but not the equals sign (field 4)
            println(join(parts, " "))
        end
    else 
        foreach(println, output_questions)
    end
end

function main()
    practice([10], 120; op=:*, minval=1, maxval=12, fill_in_the_blank=false)              
    practice([2], 120; op=:*, minval=1, maxval=12, fill_in_the_blank=false)              
    practice([5], 120; op=:*, minval=1, maxval=12, fill_in_the_blank=false)              
    practice([2,5,10], 240; op=:*, minval=1, maxval=12, fill_in_the_blank=false)
    practice([2,5,10], 240; op=:*, minval=1, maxval=12, fill_in_the_blank=true)


    # Times tables with division
#    practice(1:5, 100; op=:+, minval=0, maxval=5, inverseoperations=false, fill_in_the_blank=true)   # Number bonds (addition/subtraction)
#    practice(1:12, 24; op=:*, inverseoperations=true, fill_in_the_blank=true)
# 12 questions on an A4 sheet on Google Docs, Roboto 34, 1.5 line spacing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

