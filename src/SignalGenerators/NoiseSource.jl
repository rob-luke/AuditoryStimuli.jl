"""
    NoiseSource(eltype, samplerate, nchannels, std=1)

NoiseSource is a multi-channel noise signal generator. The noise on each channel is independent.


Inputs
------
* `samplerate` specifies the sample rate of the signal specified in Hz.
* `nchannels` specifies the number of channels of the signal.
* `std` specifies the desired standard deviation of the signal.


Output
------
* SampleSource object


Example
-------
```julia
source_object = NoiseSource(Float64, 48u"kHz", 2, 0.3)
wn = read(source_object, 480)         # Specify number of samples of signal to generate
wn = read(source_object, 50u"ms")     # Specify length of time of signal to generate
```
"""
mutable struct NoiseSource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int64
    std::Float64

    function NoiseSource(eltype, samplerate::Number, nchannels::Int, std::Number=1)
        new{eltype}(samplerate, nchannels, std)
    end
    function NoiseSource(eltype, samplerate::Unitful.Frequency, nchannels::Int, std::Number=1)
        samplerate = ustrip(uconvert(u"Hz", samplerate))
        NoiseSource(eltype, samplerate, nchannels, std)
    end
end

Base.eltype(::NoiseSource{T}) where T = T
nchannels(source::NoiseSource) = source.nchannels
samplerate(source::NoiseSource) = source.samplerate

function unsafe_read!(source::NoiseSource, buf::Array, frameoffset, framecount)
    buf[1+frameoffset:framecount+frameoffset, 1:source.nchannels] = source.std .* randn(framecount, source.nchannels)
    framecount
end
