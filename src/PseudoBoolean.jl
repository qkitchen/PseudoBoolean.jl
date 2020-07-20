module PseudoBoolean

export
    BitVar,
    BitVarArray,
    size,
    indexes,
    name,
    getindex

include("hierarchy.jl")
include("variables.jl")
include("binarymodels/binarymodels.jl")


end # module
