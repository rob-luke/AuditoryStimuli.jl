# Examples

In this section we demonstrate some common auditory signals you may wish to generate.

The examples below all begin with the following imports and default settings.

```@example
using AuditoryStimuli, Unitful, Plots
using Random; Random.seed!(0)

sample_rate = 48000
audio_channels = 2;
```



## Bandpass noise signal

```@example bp_noise
using AuditoryStimuli, Unitful, Plots # hide
using Random; Random.seed!(0) # hide
sample_rate = 48000 # hide
audio_channels = 2 # hide

noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.6u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
sound_signal = set_RMS(amplitude_modulate(filtered_noise, 10u"Hz"), 0.2)
PlotSpectroTemporal(sound_signal, time_limits = [1.2, 1.5], figure_size=(800, 400))
```


## Noise with ITD

```@example constant_itd
using AuditoryStimuli, Unitful, Plots # hide
using Random; Random.seed!(0) # hide
sample_rate = 48000 # hide
audio_channels = 2 # hide

noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.5u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
modulated_noise = amplitude_modulate(filtered_noise, 40u"Hz")
it = set_ITD(modulated_noise, -24)

time = 1:size(it, 1); time = time ./ sample_rate
a = plot(time, it, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, it, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (800, 300))
```


## Harmonic Complex

```@example harmonic_complex
using AuditoryStimuli, Unitful, Plots # hide
using Random; Random.seed!(0) # hide
sample_rate = 48000 # hide
audio_channels = 2 # hide

source = HarmonicComplex(Float64, 48000, collect(200:200:2400))
sound = read(source, 6u"s")
sound = amplitude_modulate(sound, 15u"Hz")
sound = set_RMS(sound, 0.1)
PlotSpectroTemporal(sound, frequency_limits = [0, 3000], time_limits = [0.135, 0.33], amplitude_limits = [-0.6, 0.6], figure_size=(800, 400))
```

