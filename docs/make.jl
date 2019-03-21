using Documenter, Hooks

makedocs(;
    modules=[Hooks],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/ssfrr/Hooks.jl/blob/{commit}{path}#L{line}",
    sitename="Hooks.jl",
    authors="Spencer Russell",
    assets=[],
)

deploydocs(;
    repo="github.com/ssfrr/Hooks.jl",
)
