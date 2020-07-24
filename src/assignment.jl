import Base: length, setindex!

export
    BitAssignment,
    vars,
    names,
    length,
    setindex!,
    isfilled

struct BitAssignment
    vars::Vector{AbstractVariable}
    assigned_zeros::Vector{Vector{Bool}} # which are known to be zero
    assigned_ones::Vector{Vector{Bool}}  # which are known to be one

    function BitAssignment(vars::Vector{<:AbstractVariable})
        # vars has different names
        @assert length(unique(name.(vars))) == length(vars)

        vars = sort(collect(unique(vars)))
        lengths = length.(vars)

        new(AbstractVariable[vars...], [fill(false, l) for l=lengths], [fill(false, l) for l=lengths])
    end
end

BitAssignment(v::AbstractVariable) = BitAssignment([v])
vars(a::BitAssignment) = a.vars
names(a::BitAssignment) = name.(vars(a))
length(a::BitAssignment) = sum(length.(vars(a)))

# syntax
# x = BitVar("x")
# a = BitAssignment(x)
# a["x"] = 1
# a["x"] = nothing (clear variable, always possible)
# a["xx", 1, 2] = nothing (if xx is matrix variable)
function Base.setindex!(a::BitAssignment, val::Union{Integer,Nothing}, s::String, I::Vararg)
    @assert val == 0 || val == 1 || val == nothing
    ind = findfirst(x -> name(x) == s, vars(a))
    @assert ind != nothing
    var = vars(a)[ind]
    if typeof(var) <: BitVar
        @assert length(I) == 0 "Too many arguments" # we forbid extra elements
        if val == nothing
            a.assigned_zeros[ind][1] = false
            a.assigned_ones[ind][1] = false
        elseif val == 0
            a.assigned_zeros[ind][1] = true
            a.assigned_ones[ind][1] = false
        else
            a.assigned_ones[ind][1] = true
            a.assigned_zeros[ind][1] = false
        end
    elseif typeof(var) <: BitVarArray
        @assert false "TBD"
    end
    a
end

function isfilled(a::BitAssignment)
    for (v1, v2) in zip(a.assigned_zeros, a.assigned_ones)
        if !all(v1 .| v2)
            return false
        end
    end
    false
end
