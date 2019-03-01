"""
    CorrelatedNoiseSource(eltype, samplerate, nchannels, std, correlation)

CorrelatedNoiseSource is a multi-channel (currently restricted to 2) noise signal generator.
`std` specifies the desired standard deviation of the signal.
`correlation` specifies the desired correlation between the signals.
"""
mutable struct CorrelatedNoiseSource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int64
    cholcov::Array{Float64}
end

function CorrelatedNoiseSource(eltype, samplerate::Number, nchannels::Number, std::Number, corr::Number)
    
    @assert nchannels==2 "Only two channels are supported for CorrelatedNoiseSource"

    correlation_matrix  = [1.0 corr ;  corr 1.0]
    standard_deviation  = [std 0.0 ;  0.0 std]
    covariance_matrix   = standard_deviation*correlation_matrix*standard_deviation
    cholcov = cholesky(covariance_matrix)
    cholcov = cholcov.U

    CorrelatedNoiseSource{eltype}(Float64(samplerate), Int64(nchannels), Array{Float64}(cholcov))
end

Base.eltype(::CorrelatedNoiseSource{T}) where T = T
nchannels(source::CorrelatedNoiseSource) = source.nchannels
samplerate(source::CorrelatedNoiseSource) = source.samplerate

function unsafe_read!(source::CorrelatedNoiseSource, buf::Array, frameoffset, framecount)
    buf[1+frameoffset:framecount+frameoffset, 1:source.nchannels] = randn(framecount, source.nchannels) * source.cholcov
    framecount
end

