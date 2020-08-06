using LinearAlgebra, SparseArrays
import Base: *, +, -, ^
export
    QUBO,
    +

struct QUBO{T} <: BinaryModel where {T<:Real}
    vars::Vector{AbstractVariable}
    q::SparseMatrixCSC{T,Int}
    offset::T # c_b
    function QUBO{T}(vars::Vector{<:AbstractVariable},
                     q::SparseMatrixCSC{T,Int},
                     offset::T) where {T<:Real} # offset and matrix elements of the same type T
        # TODO: check dimensions and fix q to be proper UpperTriangular
        new{T}(vars, q, offset)
    end
end

###############################################
################# conversions #################
###############################################
# sugar syntax
function QUBO(vars::Vector{<:AbstractVariable},
              q::SparseMatrixCSC{T,Int},
              offset::T) where {T<:Real}
    QUBO{T}(vars, q, offset)
end

# QUBO(1.)
function QUBO(offset::T) where T<:Real
    QUBO(AbstractVariable[], spzeros(0, 0), offset)
end

QUBO() = QUBO(0.)

function QUBO(::Type{T}, x::BitVar) where T<:Real
    q = spzeros(T, 1, 1)
    q[1] = one(T)
    QUBO([x], q, zero(T))
end

QUBO(x::BitVar) = QUBO(Float64, x)

function QUBO(::Type{T}, x::BitVarSubArray) where T<:Real
    @assert all(indexes(x) .> 0) # conversion of non-trivial subarray to QUBO is not specified
    n = prod(size(x))
    ind = mixed_radix_conv(indexes(x), size(x))
    q = spzeros(T, n, n)
    q[ind,ind] = one(T)
    QUBO([x.var], q, zero(T))
end

QUBO(x::BitVarSubArray) = QUBO(Float64, x)

###############################################
################## calls ######################
###############################################

# syntax
# julia> x = BitVar("x")
# julia> a = BitAssignment(x)
# julia> a["x"] = 1
# julia> q = QUBO(x)
# julia> q(a)
function (qubo::QUBO)(a::BitAssignment)
    @assert false "TBD"
end

###############################################
################## utils ######################
###############################################

function enlarge(qubo::QUBO{T}, vars::Vector{<:AbstractVariable}) where T
    vars = sort(collect(unique(vcat(qubo.vars, vars))))
    println(vars)
    n = sum(length.(vars))
    len_qubo = sum(length.(qubo.vars))
    q = spzeros(T, n, n)
    for i = 1:len_qubo
        new_i = findfirst(var -> var.name == qubo.vars[i].name, vars)
        # TODO: fix the loop if we are sure Q is UpperTriangular
        # for j = 1:len_qubo - i + 1
        for j = 1:len_qubo
            new_j = findfirst(var -> var.name == qubo.vars[j].name, vars)
            q[new_i][new_j] = qubo.q[i][j]
        end
    end
    return QUBO(vars, q, qubo.offset)
end


###############################################
################## operations #################
###############################################

function +(qubo::QUBO, x::Real)
    QUBO(qubo.vars, qubo.q, x+qubo.offset)
end

+(x::Real, qubo::QUBO) = qubo + x

function +(qubo1::QUBO, qubo2::QUBO)
    if qubo1.vars == qubo2.vars
        return QUBO(qubo1.vars, qubo1.q + qubo2.q, qubo1.offset + qubo2.offset)
    else
        new_vars = sort(collect(unique(vcat(qubo1.vars, qubo2.vars))))
        qubo1_enl = enlarge(qubo1, qubo2.vars) # change to common dimension
        qubo2_enl = enlarge(qubo2, qubo1.vars)
        return QUBO(new_vars, qubo1_enl.q + qubo2_enl.q, qubo1.offset + qubo2.offset)
    end
end

# TODO implement +, - (binary and unary), *, ^
# remember to export (top of the file)!
