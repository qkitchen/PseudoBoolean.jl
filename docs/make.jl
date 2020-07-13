using Documenter, PseudoBoolean

makedocs(
    modules = [PseudoBoolean],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Adam Glos",
    sitename = "PseudoBoolean.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/qkitchen/PseudoBoolean.jl.git",
    push_preview = true
)
