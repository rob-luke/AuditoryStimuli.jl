"""
    HarmonicComplex(eltype, samplerate, freqs)

HarmonicComplex is a single-channel sine-tone signal generator. `freqs` can be an
array of frequencies for a multi-frequency source, or a single frequency for a
mono source.
"""
mutable struct HarmonicComplex{T} <: SampleSource
    samplerate::Float64
    freqs::Vector{Float64} # in radians/sample
    phases::Vector{Float64}
end

function HarmonicComplex(eltype, samplerate, freqs::Array)
    # convert frequencies from cycles/sec to rad/sample
    radfreqs = map(f->2pi*f/samplerate, freqs)
    HarmonicComplex{eltype}(Float64(samplerate), radfreqs, zeros(length(freqs)))
end

# also allow a single frequency
HarmonicComplex(eltype, samplerate, freq::Real) = HarmonicComplex(eltype, samplerate, [freq])

Base.eltype(::HarmonicComplex{T}) where T = T
nchannels(source::HarmonicComplex) = 1
samplerate(source::HarmonicComplex) = source.samplerate

function unsafe_read!(source::HarmonicComplex, buf::Array, frameoffset, framecount)
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
