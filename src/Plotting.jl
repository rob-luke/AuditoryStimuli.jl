
using Plots
using Statistics

"""
    PlotSpectroTemporal(data, sample_rate)

This function plots the time, spectrogram, and periodogram of a signal

"""
function PlotSpectroTemporal(x::AbstractArray, sample_rate::Number; 
                                figure_size::Tuple=(950, 450), 
                                window = hamming,
                                amplitude_limits = [-1, 1],
                                time_limits = nothing,
                                frequency_limits = [0, 1500],
                                correlation_annotate = true, args...)

    # Generate time vector
    t = 1:size(x, 1) 
    t = t ./ sample_rate
    if time_limits == nothing
        time_limits = [0, maximum(t)]
    end

    # Calculate signal transforms
    spec = spectrogram(x[:, 1], 1024, 256, fs = sample_rate, window = window)
    peri1 = welch_pgram(x[:, 1], 2048, 512, fs = sample_rate)
    if size(x, 2)>1; peri2 = welch_pgram(x[:, 2], 2048, 512, fs = sample_rate); end
    tfft = fft(x[:, 1])

    # Create plots
    spec_plot = heatmap(time(spec), freq(spec), power(spec), colorbar = false, xlab = "Time (s)", ylab = "Frequency (Hz)", ylims = frequency_limits, xlims = time_limits)

    peri_plot = plot(vector_pow2db(power(peri1)), freq(peri1), yticks = [], xlab = "Power (dB)", lab = "", ylims = frequency_limits)
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
    return plot(time_plot, corr_plot, spec_plot, peri_plot, layout = l, size = figure_size, link = :none; args...)

end

function PlotSpectroTemporal(x::SampledSignals.SampleBuf; 
                             figure_size::Tuple=(950, 450), 
                             window = hamming,
                             amplitude_limits = [-1, 1],
                             time_limits = nothing,
                             frequency_limits = [0, 1500],
                             correlation_annotate = true)

    PlotSpectroTemporal(x.data, x.samplerate, figure_size = figure_size, window = window, amplitude_limits = amplitude_limits, 
                        time_limits = time_limits, frequency_limits = frequency_limits, correlation_annotate = correlation_annotate)

end


function vector_pow2db(a::Vector)
    for index = 1:size(a, 1)
        a[index] = pow2db(a[index])
    end
    return a
end;
