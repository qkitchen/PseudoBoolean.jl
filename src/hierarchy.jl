abstract type BinaryModel end
abstract type BitModel <: BinaryModel end
abstract type SpinModel <: BinaryModel end

abstract type AbstractVariable end
abstract type AbstractBitVariable <: AbstractVariable end
abstract type AbstractSpinVariable <: AbstractVariable end
