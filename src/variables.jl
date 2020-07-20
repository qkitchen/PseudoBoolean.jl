name(v::AbstractVariable) = v.name

struct BitVar <: AbstractVariable
    name::String
    function BitVar(name::String)
        @assert length(name) > 0
        new(name)
    end
end

size(::BitVar) = 1 # BitVar always has one element
length(::BitVar) = 1 # BitVar always has one element

struct BitVarArray  <: AbstractVariable
    name::String
    size::Vector{Int}
    function BitVarArray(name::String,
                         size::Vector{Int})
        @assert name != ""
        @assert length(size) > 0
        @assert all(0 .< size)
        new(name, size)
    end
end

size(v::BitVarArray) = v.size
length(v::BitVarArray) = prod(size(v))

struct BitVarSubArray  <: AbstractVariable
    var::BitVarArray
    indexes::Vector{Int}
    function BitVarSubArray(var::BitVarArray,
                            indexes::Vector{Int})
        @assert length(indexes) == length(size(var))
        @assert all(0 .<= indexes .<= size(var)) # 0 means "all"
        new(var, indexes)
    end
end

name(v::BitVarSubArray) = name(v.var)
size(v::BitVarSubArray) = size(v.var)
length(v::BitVarSubArray) = prod(size(v))
indexes(v::BitVarSubArray) = v.indexes

# for syntax:
# var = BitVarArray("mine", [3,2,3])
# var2 = var[:,2,:]
# TODO syntax var[:,:,[1,3]] or var[:,:,1:2]
function Base.getindex(var::BitVarArray, I::Vararg)
    I = map(x-> ifelse(x == Colon(), 0, x), I)
    BitVarSubArray(var, Int[I...])
end

isless(v::BitVar, w::BitVar) = (name(v) <= name(w))
isless(v::BitVar, w::BitVarArray) = true
isless(v::BitVarArray, w::BitVar) = false
function isless(v::BitVarArray, w::BitVarArray)
    if name(v) == name(w)
        return size(v) <= size(w)
    else
        return size(v) <= size(w)
    end
end
