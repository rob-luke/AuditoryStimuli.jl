using AuditoryStimuli, Unitful, Plots
using Random; Random.seed!(0)

sample_rate = 48000
audio_channels = 2


# Generate 1.5 s of bandpass (300-700 Hz) correlated (0.8) noise 

noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.5u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
sound_signal = set_RMS(amplitude_modulate(filtered_noise, 40u"Hz"), 0.2)
PlotSpectroTemporal(sound_signal, time_limits = [0.155, 0.345])
savefig("examples/eg2.png")


# Generate 1.5 s of amplitude modulated (40 Hz) bandpass (300-700 Hz) correlated (0.8) noise with an ITD of 500 μs (24 samples)

noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.5u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
modulated_noise = amplitude_modulate(filtered_noise, 40u"Hz")
it = set_ITD(modulated_noise, -24)

time = 1:size(it, 1); time = time ./ sample_rate
a = plot(time, it, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, it, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (1000, 400))
savefig("examples/am_itd.png")


