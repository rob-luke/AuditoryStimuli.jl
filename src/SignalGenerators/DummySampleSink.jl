# This code is from https://github.com/JuliaAudio/SampledSignals.jl/blob/2d078e86489232f77af3696f0ea6d0e34016e7b0/test/support/util.jl
# Copyright (c) 2015: Spencer Russell. Released under the MIT "Expat" License.
mutable struct DummySampleSink{T} <: SampleSink
    samplerate::Float64
    buf::Array{T, 2}
end

DummySampleSink(eltype, samplerate::Number, channels::Int) =
    DummySampleSink{eltype}(samplerate, Array{eltype}(undef, 0, channels))
function DummySampleSink(eltype, samplerate::Union{typeof(1u"Hz"), typeof(1u"kHz")}, 
                         nchannels::Int)
    samplerate = ustrip(uconvert(u"Hz", samplerate))
    DummySampleSink(eltype, samplerate, nchannels)
end

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


# ######################
# Plotting
# ######################

PlotSpectroTemporal(x::AuditoryStimuli.DummySampleSink; kwargs...) = PlotSpectroTemporal(x.buf, x.samplerate; kwargs...)

function plot(x::AuditoryStimuli.DummySampleSink;
                xlab::String = "Time (s)",
                ylab::String = "Amplitude",
                kwargs...)

    t = 1:size(x.buf, 1) 
    t = t ./ x.samplerate

    plot(t, x.buf, xlab = xlab, ylab = ylab; kwargs...)
end

