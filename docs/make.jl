push!(LOAD_PATH,"../src/")
using Documenter, AuditoryStimuli

makedocs(
    modules = [AuditoryStimuli],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "AuditoryStimuli.jl",
    authors  = "Robert Luke",
    pages = [
        "Home" => "index.md",
        "Introduction / Tutorial" => "realtime-introduction.md",
        "Examples" => Any[
            "Amplitude Modulated Noise" => "example-ssr.md",
            "Harmonic Stacks" => "example-hs.md",
            "Bandpass Noise" => "example-bpnoise.md",
        ],
        "Offline Audio Generation" => "offline-introduction.md",
        "API" => "api.md"
    ]
)


deploydocs(
    repo = "github.com/rob-luke/AuditoryStimuli.jl.git",
    push_preview = true,
)
