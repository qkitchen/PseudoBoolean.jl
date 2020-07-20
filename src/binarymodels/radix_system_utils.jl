# TODO probably deserves separate struct, or deeper looking into internet
function mixed_radix_conv(indexes::Vector{Int}, dims::Vector{Int})
    @assert length(indexes) == length(dims)
    ind = 1 # because Julia enumerates from 1
    d_prod = 1
    for (i, d) = reverse(collect(zip(indexes .- 1, dims)))
        ind += d_prod*i
        d_prod *= d
    end
    ind
end

function mixed_radix_conv(index::Int, dims::Vector{Int})
    @assert 1 <= index <= prod(dims)
    index -= 1
    n = length(dims)
    res = ones(Int, n)
    for (ind, d) = enumerate(reverse(dims))
        res[ind] += index % d
        index = div(index, d)
    end
    reverse(res)
end
