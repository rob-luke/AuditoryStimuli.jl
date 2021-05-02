# Examples

!!! warning "Depreciation Warning"
    These offline examples are being transitioned to the standard examples format above and may change with no warning. Use at your own risk.

In this section we demonstrate some common auditory signals you may wish to generate.

The examples below all begin with the following imports and default settings.

```@example
using AuditoryStimuli, Unitful, Plots
using DisplayAs # hide
using Random; Random.seed!(0)

sample_rate = 48000
audio_channels = 2;
```

## Noise with ITD

```@example constant_itd
using AuditoryStimuli, Unitful, Plots # hide
using Random; Random.seed!(0) # hide
sample_rate = 48000 # hide
audio_channels = 2 # hide
using DisplayAs # hide

noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.5u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
modulated_noise = amplitude_modulate(filtered_noise, 40u"Hz")
it = set_ITD(modulated_noise, -24)

time = 1:size(it, 1); time = time ./ sample_rate
a = plot(time, it, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, it, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (700, 300))
current() |> DisplayAs.PNG # hide
```


