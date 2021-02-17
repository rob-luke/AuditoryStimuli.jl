push!(LOAD_PATH,"../src/")
using Documenter, AuditoryStimuli

makedocs(
    modules = [AuditoryStimuli],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "AuditoryStimuli.jl",
    authors  = "Robert Luke",
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "API" => "api.md"
    ]
)
