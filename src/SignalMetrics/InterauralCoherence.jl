using StatsBase

"""
    interaural_coherence(x::SampleBuf, lags::Unitful.Time)

Compute the interaural coherence of a two channel sound signals.

Interaural coherence (IAC) is commonly defined as the 
peak of the cross-correlation coefficient of the signals at the two ears [1, 2].
It is commonly computed over a restricted range of `lags` of the cross-correlation function.


Inputs
------
* `x` data in the form of SampledSignals.SampleBuf. Must be two channels of audio.
* `lags` time range of lags to be used for finding maximum in cross correlation function.
  If lags=0, then the entire function will be used, effecively same as lags=Inf.



References
----------

1. Chait, M., Poeppel, D., de Cheveigne, A., and Simon, J.Z. (2005). Human auditory cortical processing of changes in interaural correlation. J Neurosci 25, 8518-8527.
2. Aaronson, N.L., and Hartmann, W.M. (2010). Interaural coherence for noise bands: waveforms and envelopes. J Acoust Soc Am 127, 1367-1372.

Example
-------
```julia
correlation = 0.6
source = CorrelatedNoiseSource(Float64, 48000, 2, 0.1, correlation) 
a = read(source, 3u"s")
@test interaural_coherence(a.data) ≈ correlation atol = 0.025
```

"""
function interaural_coherence(x::T; lags::AbstractQuantity=0u"s")::Float64 where {T<:SampledSignals.SampleBuf}

    lags_seconds = lags |> u"s" |> ustrip
    lags_samples = Int(lags_seconds * x.samplerate)
    interaural_coherence(x.data; lags=lags_samples)
end

function interaural_coherence(x::T; lags::AbstractQuantity=0u"s")::Float64 where {T<: DummySampleSink}

    lags_seconds = lags |> u"s" |> ustrip
    lags_samples = Int(lags_seconds * x.samplerate)
    interaural_coherence(x.buf; lags=lags_samples)
end

function interaural_coherence(x::Array{T, 2}; lags::Int=0)::Float64 where {T<:Number}

    if lags == 0
        lags = size(x, 1) - 1
    end

    cc = crosscor(x[:, 1], x[:, 2], -lags:lags)
    iac = maximum(cc)
end



