"""
    CorrelatedNoiseSource(eltype, samplerate, nchannels, std, correlation)

CorrelatedNoiseSource is a two-channel  noise signal generator with controlled correlation between channels.


Inputs
------
* `samplerate` specifies the sample rate of the signal.  
* `nchannels` specifies the number of channels of the signal.  
* `std` specifies the desired standard deviation of the signal.  
* `correlation` specifies the desired correlation between the signals.


Output
------
* SampleSource object


Example
-------
```julia
source_object = CorrelatedNoiseSource(Float64, 48000, 2, 0.3, 0.75)
cn = read(source_object, 480)         # Specify number of samples of signal to generate
cn = read(source_object, 50u"ms")     # Specify length of time of signal to generate
```
"""
mutable struct CorrelatedNoiseSource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int64
    cholcov::Array{Float64}

    function CorrelatedNoiseSource(eltype, samplerate::Number, nchannels::Number, std::Number, corr::Number)
        
        @assert nchannels==2 "Only two channels are supported for CorrelatedNoiseSource"

        if corr < 1
            correlation_matrix  = [1.0 corr ;  corr 1.0]
            standard_deviation  = [std 0.0 ;  0.0 std]
            covariance_matrix   = standard_deviation*correlation_matrix*standard_deviation
            cholcov = cholesky(covariance_matrix)
            cholcov = cholcov.U
        else
            cholcov = [std std ; 0 0]
        end 

        new{eltype}(Float64(samplerate), Int64(nchannels), Array{Float64}(cholcov))
    end

    function CorrelatedNoiseSource(eltype, samplerate::Unitful.Frequency, nchannels::Number, std::Number, corr::Number)
        samplerate = ustrip(uconvert(u"Hz", samplerate))
        CorrelatedNoiseSource(eltype, samplerate, nchannels, std, corr)
    end
end


Base.eltype(::CorrelatedNoiseSource{T}) where T = T
nchannels(source::CorrelatedNoiseSource) = source.nchannels
samplerate(source::CorrelatedNoiseSource) = source.samplerate

function unsafe_read!(source::CorrelatedNoiseSource, buf::Array, frameoffset, framecount)
    buf[1+frameoffset:framecount+frameoffset, 1:source.nchannels] = randn(framecount, source.nchannels) * source.cholcov
    framecount
end

