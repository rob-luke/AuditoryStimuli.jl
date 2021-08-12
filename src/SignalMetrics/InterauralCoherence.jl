using StatsBase

"""
    interaural_coherence(x::SampleBuf, lags::Unitful.Time)

Compute the interaural coherence of two sound signals.

Interaural coherence (IAC) is commonly defined as the 
peak of the cross-correlation coefficient of the signals at the two ears [1, 2].


Inputs
------
* `x` data in the form of SampledSignals.SampleBuf.
* `lags` time range of lags to be used for finding maximum in cross correlation function.
  If lags=0, then the entire function will be used, effecively same as lags=Inf.


TODO
----

Inf is a float not int

References
----------

1. Chait, M., Poeppel, D., de Cheveigne, A., and Simon, J.Z. (2005). Human auditory cortical processing of changes in interaural correlation. J Neurosci 25, 8518-8527.
2. Aaronson, N.L., and Hartmann, W.M. (2010). Interaural coherence for noise bands: waveforms and envelopes. J Acoust Soc Am 127, 1367-1372.


"""
function interaural_coherence(x::SampledSignals.SampleBuf; lags::AbstractQuantity=0u"s")

    lags_seconds = lags |> u"s" |> ustrip
    lags_samples = Int(lags_seconds * x.samplerate)
    return interaural_coherence(x.data; lags=lags_samples)
end

function interaural_coherence(x::Array{T, 2}; lags::Int=0) where {T<:Number}

    if lags == 0
        lags = Inf
    end

    if lags == Inf
        iac = cor(x)[2, 1]
    else
        cc = crosscor(x[:, 1], x[:, 2], -lags:lags)
        iac = maximum(cc)
    end

    return iac
end



