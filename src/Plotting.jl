
using Plots
using Statistics

"""
    PlotSpectroTemporal(data, sample_rate)

This function plots the time, spectrogram, and periodogram of a signal.

"""
function PlotSpectroTemporal(x::AbstractArray, sample_rate::Number; 
                                figure_size::Tuple=(750, 400), 
                                window = hamming,
                                amplitude_limits = nothing,
                                power_limits = nothing,
                                time_limits = nothing,
                                frequency_limits = [0, 1500],
                                correlation_annotate = true, kwargs...)

    # Generate time vector
    t = 1:size(x, 1) 
    t = t ./ sample_rate
    if time_limits == nothing
        time_limits = [0, maximum(t)]
    end

    # Calculate signal transforms
    spec = spectrogram(x[:, 1], 1024, 256, fs = sample_rate, window = window)
    peri1 = welch_pgram(x[:, 1], 2048, 512, fs = sample_rate)
    peri1_power = vector_pow2db(power(peri1))
    if size(x, 2)>1; peri2 = welch_pgram(x[:, 2], 2048, 512, fs = sample_rate); end
    tfft = fft(x[:, 1])

    # Extract required stats
    if isnothing(amplitude_limits)
        amplitude_limits = maximum(abs.(x))
        amplitude_limits = (-amplitude_limits, amplitude_limits)
    end
    if isnothing(power_limits)
        idxs = (freq(peri1) .> frequency_limits[1]) .& (freq(peri1) .< frequency_limits[2])
        power_limits = (minimum(peri1_power[idxs]), maximum(peri1_power[idxs]))
    end

    # Create plots
    spec_plot = heatmap(time(spec), freq(spec), power(spec), colorbar = false, xlab = "Time (s)", ylab = "Frequency (Hz)", ylims = frequency_limits, xlims = time_limits)

    peri_plot = plot(peri1_power, freq(peri1), yticks = [], xlab = "Power (dB)", lab = "", ylims = frequency_limits, xlims = power_limits)
    if size(x, 2)>1; peri_plot = plot!(vector_pow2db(power(peri2)), freq(peri2), yticks = [], xlab = "Power (dB)", lab = "", ylims = frequency_limits); end

    time_plot = plot(t, x, xticks = [], leg = false, ylab = "Amplitude", lab = "", ylims = amplitude_limits, xlims = time_limits)
    
    corr_plot = histogram(x, orientation = :h,  ticks = [], leg = false, framestyle = :none, link = :none, bins=LinRange(amplitude_limits[1], amplitude_limits[2], 15), ylims = amplitude_limits)
    if ((size(x, 2)>1) & correlation_annotate) 

        maximum_hist_val = maximum(corr_plot.series_list[2].plotattributes[:y][.~isnan.(corr_plot.series_list[2].plotattributes[:y])])

        d = annotate!(0, 0.9 * maximum(amplitude_limits), text(string("Corr = ", round(cor(x)[2, 1], digits=3)),:left,8))
        d = annotate!(0, -0.9 * maximum(amplitude_limits), text(string("Std = ", round(std(x), digits=3)),:left,8))
    end

    # Return all plots in layout
    l = Plots.@layout [c{0.6w, 0.3h} d  ; a{0.8w} b]
    return plot(time_plot, corr_plot, spec_plot, peri_plot, layout = l, size = figure_size, link = :none; kwargs...)

end


function vector_pow2db(a::Vector)
    for index = 1:size(a, 1)
        a[index] = pow2db(a[index])
    end
    return a
end


function plot_cross_correlation(x::T; lags::AbstractQuantity=0u"s") where {T<:SampledSignals.SampleBuf}

    lags_seconds = lags |> u"s" |> ustrip
    lags_samples = Int(lags_seconds * x.samplerate)
    plot_cross_correlation(x.data, lags_samples, x.samplerate)
end

function plot_cross_correlation(x::T; lags::AbstractQuantity=0u"s") where {T<:DummySampleSink}

    lags_seconds = lags |> u"s" |> ustrip
    lags_samples = Int(lags_seconds * x.samplerate)
    plot_cross_correlation(x.buf, lags_samples, x.samplerate)
end


"""
    plot_cross_correlation(x::SampleBuf, lags::Unitful.Time)

Plot the cross correlation

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
function plot_cross_correlation(x::Array{T, 2}, lags::Int, samplerate::Number) where {T<:Number}

    if lags == 0
        lags = size(x, 1) - 1
    end
    lags = round.(Int, -lags:1:lags)

    lag_times = lags ./ samplerate
    lag_times = lag_times .* 1.0u"s"

    plot(lag_times, crosscor(x[:, 1], x[:, 2], lags),
         label="", ylab="Cross Correlation", xlab="Lag", ylims=(-1, 1))

end

