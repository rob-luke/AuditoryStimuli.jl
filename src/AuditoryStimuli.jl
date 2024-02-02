"""
A Julia package for generating auditory stimuli.

"""
module AuditoryStimuli

using DSP
using SampledSignals
using LinearAlgebra
using Random
using Logging
using FFTW
using Unitful
using Plots
using Parameters

using Unitful: AbstractQuantity, AffineQuantity, DimensionlessQuantity
import SampledSignals: nchannels, samplerate, unsafe_read!
import Plots: plot

export  bandpass_noise,
        bandpass_filter,
        amplitude_modulate,
        ITD_modulate,
        set_RMS,
        ramp_on,
        ramp_off,
        set_ITD,
        PlotSpectroTemporal,
        NoiseSource,
        CorrelatedNoiseSource,
        SinusoidSource,
        DummySampleSink,
        Amplification,
        AmplitudeModulation,
        TimeDelay,
        samplerate,
        modify,
        plot,
        interaural_coherence,
        plot_cross_correlation




# #########################################
# #####  Signal Generation
# #########################################

include("SignalGenerators/NoiseSource.jl")
include("SignalGenerators/CorrelatedNoiseSource.jl")
include("SignalGenerators/SinusoidSource.jl")
include("SignalGenerators/DummySampleSink.jl")

# #########################################
# #####  Signal Modifiers
# #########################################

include("SignalModifiers/Amplification.jl")
include("SignalModifiers/BandpassFilter.jl")
include("SignalModifiers/Modulation.jl")
include("SignalModifiers/TimeDelay.jl")

# #########################################
# #####  Signal Metrics
# #########################################

include("SignalMetrics/InterauralCoherence.jl")

# #########################################
# #####  Signal Plotting
# #########################################

include("Plotting.jl")


"""
    bandpass_noise(number_samples, number_channels, lower_bound, upper_bound, sample_rate; filter_order=14)

Generates band pass noise with specified upper and lower bounds using a butterworth filter.
"""
function bandpass_noise(number_samples::Int, number_channels::Int, lower_bound::Number, upper_bound::Number, sample_rate::Number; filter_order::Int = 14)
    bandpass_filter(randn(number_samples, number_channels), lower_bound, upper_bound, sample_rate, filter_order=filter_order)
end




# #########################################
# #####  Signal Modifiers
# #########################################


"""
    bandpass_filter(AbstractArray, lower_bound, upper_bound, sample_rate; filter_order=14)
    bandpass_filter(SampledSignal, lower_bound, upper_bound;              filter_order=14)

Signal will be filtered with bandpass butterworth filter between 'lower_bound' and `upper_bound` with filter of `filter_order`.
"""
function bandpass_filter(x::AbstractArray, lower_bound::Number, upper_bound::Number, sample_rate::Number; filter_order::Int = 14)

    responsetype = Bandpass(lower_bound, upper_bound; fs=sample_rate)
    designmethod = Butterworth(filter_order)
    filt(digitalfilter(responsetype, designmethod), x)
end

function bandpass_filter(x::SampledSignals.SampleBuf, lower_bound::typeof(1u"Hz"), upper_bound::typeof(1u"Hz"); filter_order::Int = 14)
    x.data = bandpass_filter(x.data, ustrip(lower_bound), ustrip(upper_bound), x.samplerate, filter_order=filter_order)
    x
end



"""
    amplitude_modulate(data, modulation_frequency, sample_rate; phase=π)

Amplitude modulates the signal

See [wikipedia](https://en.wikipedia.org/wiki/Amplitude_modulation)
"""
function amplitude_modulate(x::AbstractArray, modulation_frequency::Number, sample_rate::Number; phase::Number = π)

    t = 1:size(x, 1)
    t = t ./ sample_rate

    fits = mod(maximum(t), (1/modulation_frequency))
    if !(isapprox(fits, 0, atol = 1e-5) || isapprox(fits, 1/modulation_frequency, atol = 1e-5)  )
        @warn("Not a complete modulation")
    end
        # println(maximum(t))
    # println(1/modulation_frequency)
    # println(mod(maximum(t), (1/modulation_frequency)))

    M = 1 .* cos.(2 * π * modulation_frequency * t .+ phase)
    (1 .+ M) .* x;
end


function amplitude_modulate(x::SampledSignals.SampleBuf, modulation_frequency::typeof(1u"Hz"); phase::Number = π)
    amplitude_modulate(x, modulation_frequency * 1.0, phase=phase)

end

function amplitude_modulate(x::SampledSignals.SampleBuf, modulation_frequency::typeof(1.0u"Hz"); phase::Number = π)
    x.data = amplitude_modulate(x.data, ustrip(modulation_frequency), x.samplerate, phase=phase)
    x
end


"""
    ITD_modulate(data, modulation_frequency, ITD_1, ITD_2, samplerate)

Modulate an applied ITD

"""
function ITD_modulate(x::AbstractArray, modulation_frequency::Number, ITD_1::Int, ITD_2::Int, sample_rate)
    @warn "Unvalidated code"

    t = 1:size(x, 1)
    t = t ./ sample_rate

    Ti = 1 / modulation_frequency
    switches = round.(Int, collect(0:Ti:maximum(t))*sample_rate)
    switches_starts = switches[1:1:end]
    switches_stops  = switches[2:1:end]

    switch_samples = switches_stops[1] - switches_starts[1]

    for idx = 1:2:length(switches_starts)-1
        x[switches_starts[idx]+1:switches_stops[idx], 1]  = x[switches_starts[idx]+1+ITD_1:switches_stops[idx]+ITD_1, 1]  .* tukey(switch_samples, 0.01)
        x[switches_stops[idx]+1:switches_stops[idx+1], 1] = x[switches_stops[idx]+1+ITD_2:switches_stops[idx+1]+ITD_2, 1] .* tukey(switch_samples, 0.01)
    end
    return x
end


"""
    set_RMS(data, desired_rms)

Modify rms of signal to desired value

"""
function set_RMS(data::AbstractArray, desired_rms::Number)

    data / (rms(data) / desired_rms)

end


"""
    ramp_on(data, number_samples)

Apply a linear ramp to start of signal

"""
function ramp_on(data::AbstractArray, number_samples::Int)

    data[1:number_samples, :] = LinRange(0, 1, number_samples) .* data[1:number_samples, :]
    return data
end


"""
    ramp_off(data, number_samples)

Apply a linear ramp to end of signal

"""
function ramp_off(data::AbstractArray, number_samples::Int)

    data[end-number_samples+1:end, :] = LinRange(1, 0, number_samples) .* data[end-number_samples+1:end, :]
    return data
end


"""
    set_ITD(data, number_samples)

Introduce an ITD of number_samples

"""
function set_ITD(data::AbstractArray, number_samples::Int)

    abs_number_samples = abs(number_samples)

    if number_samples > 0
        data[:, 1] = [zeros(abs_number_samples, 1); data[1:end - abs_number_samples, 1]]
    elseif number_samples < 0
        data[:, 2] = [zeros(abs_number_samples, 1); data[1:end - abs_number_samples, 2]]
    end

    return data
end


end # module
