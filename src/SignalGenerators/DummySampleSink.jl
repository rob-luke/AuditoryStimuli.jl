# This code is from https://github.com/JuliaAudio/SampledSignals.jl/blob/2d078e86489232f77af3696f0ea6d0e34016e7b0/test/support/util.jl
# Copyright (c) 2015: Spencer Russell. Released under the MIT "Expat" License.
mutable struct DummySampleSink{T} <: SampleSink
    samplerate::Float64
    buf::Array{T, 2}
end

DummySampleSink(eltype, samplerate, channels) =
    DummySampleSink{eltype}(samplerate, Array{eltype}(undef, 0, channels))

samplerate(sink::DummySampleSink) = sink.samplerate
nchannels(sink::DummySampleSink) = size(sink.buf, 2)
Base.eltype(sink::DummySampleSink{T}) where T = T

function SampledSignals.unsafe_write(sink::DummySampleSink, buf::Array,
                                     frameoffset, framecount)
    eltype(buf) == eltype(sink) || error("buffer type ($(eltype(buf))) doesn't match sink type ($(eltype(sink)))")
    nchannels(buf) == nchannels(sink) || error("buffer channel count ($(nchannels(buf))) doesn't match sink channel count ($(nchannels(sink)))")

    sink.buf = vcat(sink.buf, view(buf, (1:framecount) .+ frameoffset, :))

    framecount
end

function PlotSpectroTemporal(x::AuditoryStimuli.DummySampleSink; 
                             figure_size::Tuple=(950, 450), 
                             window = hamming,
                             amplitude_limits = nothing,
                             power_limits = nothing,
                             time_limits = nothing,
                             frequency_limits = [0, 1500],
                             correlation_annotate = true)

    PlotSpectroTemporal(x.buf, x.samplerate, figure_size = figure_size, window = window, amplitude_limits = amplitude_limits, 
                        time_limits = time_limits, frequency_limits = frequency_limits, correlation_annotate = correlation_annotate)

end


function plot(x::AuditoryStimuli.DummySampleSink,
        figure_size::Tuple=(800, 300))

    t = 1:size(x.buf, 1) 
    t = t ./ x.samplerate

    plot(t, x.buf, size = figure_size, xlab = "Time (s)", ylab = "Amplitude")
    
end

                              
