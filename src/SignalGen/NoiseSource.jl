"""
    NoiseSource(eltype, samplerate, nchannels, std)

NoiseSource is a multi-channel noise signal generator. `std` specifies
the desired standard deviation of the signal.
"""
mutable struct NoiseSource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int64
    std::Float64
end

function NoiseSource(eltype, samplerate, nchannels, std)
    NoiseSource{eltype}(Float64(samplerate), Int64(nchannels), Float64(std))
end
function NoiseSource(eltype, samplerate, nchannels)
    NoiseSource(eltype, samplerate, nchannels, 1)
end

Base.eltype(::NoiseSource{T}) where T = T
nchannels(source::NoiseSource) = source.nchannels
samplerate(source::NoiseSource) = source.samplerate

function unsafe_read!(source::NoiseSource, buf::Array, frameoffset, framecount)
    buf[1+frameoffset:framecount+frameoffset, 1:source.nchannels] = source.std .* randn(framecount, source.nchannels)
    framecount
end
