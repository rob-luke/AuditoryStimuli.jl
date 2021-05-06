"""
    SinusoidSource(eltype, samplerate, freqs)

SinusoidSource is a single-channel sine-tone signal generator. `freqs` can be an
array of frequencies for a multi-frequency source, or a single frequency for a
single sinusoid source.


Inputs
------
* `samplerate` specifies the sample rate of the signal.  
* `freqs` sinusoid frequencies to generate.  


Output
------
* SampleSource object


Example
-------
```julia
source_object = SinusoidSource(Float64, 48u"kHz", 200:200:2400)
cn = read(source_object, 50u"ms")     # Generate 50 ms of harmonic stack audio
```
"""
mutable struct SinusoidSource{T} <: SampleSource
    samplerate::Float64
    freqs::Vector{Float64} # in radians/sample
    phases::Vector{Float64}

    function SinusoidSource(eltype, samplerate::Number, freqs::Array)
        # convert frequencies from cycles/sec to rad/sample
        radfreqs = map(f->2pi*f/samplerate, freqs)
        new{eltype}(Float64(samplerate), radfreqs, zeros(length(freqs)))
    end
    SinusoidSource(eltype, samplerate, freq::StepRange) = SinusoidSource(eltype, samplerate, collect(freq))
    SinusoidSource(eltype, samplerate::Number, freq::Real) = SinusoidSource(eltype, samplerate, [freq])
    SinusoidSource(eltype, samplerate::Unitful.Frequency, freq::Real) = SinusoidSource(eltype, samplerate |> u"Hz" |> ustrip, [freq])
    SinusoidSource(eltype, samplerate::Unitful.Frequency, freq::Array) = SinusoidSource(eltype, samplerate |> u"Hz" |> ustrip, freq)
end


Base.eltype(::SinusoidSource{T}) where T = T
nchannels(source::SinusoidSource) = 1
samplerate(source::SinusoidSource) = source.samplerate

function unsafe_read!(source::SinusoidSource, buf::Array, frameoffset, framecount)
    inc = 2pi / samplerate(source)

    for i in 1:framecount
        buf[i+frameoffset, 1] = 0
    end


    for tone_idx in 1:length(source.freqs)
        tone_freq = source.freqs[tone_idx]
        tone_phas = source.phases[tone_idx]

        for i in 1:framecount
            buf[i+frameoffset, 1] += sin.(tone_phas)
            tone_phas += tone_freq
        end
        source.phases[tone_idx] = tone_phas

    end

    framecount
end
