# AuditoryStimuli

[![Build Status](https://travis-ci.org/rob-luke/AuditoryStimuli.jl.svg?branch=master)](https://travis-ci.org/rob-luke/AuditoryStimuli.jl)
[![codecov.io](http://codecov.io/github/rob-luke/AuditoryStimuli.jl/coverage.svg?branch=master)](http://codecov.io/github/rob-luke/AuditoryStimuli.jl?branch=master)

Generate common auditory stimuli.  
Built on top of [SampledSignals](https://github.com/JuliaAudio/SampledSignals.jl), [Unitful](https://github.com/ajkeller34/Unitful.jl), and [Plots](https://github.com/JuliaPlots/Plots.jl).

## Installation

```julia
] dev https://github.com/rob-luke/AuditoryStimuli.jl.git
```


## Coming soon

Examples from research papers...


## Examples

Generate 1.5 s of amplitude modulated (40 Hz) bandpass (300-700 Hz) correlated (0.8) noise 

```julia
# Create a signal source and generate 1.5 s of audio
noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.6u"s")

# Signal modifiers
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
sound_signal = set_RMS(amplitude_modulate(filtered_noise, 10u"Hz"), 0.2)

# Plot generated signal
PlotSpectroTemporal(sound_signal, time_limits = [1.2, 1.5])
```

![am_itd](examples/eg2.png)

----------------------------------------------------------------------------

Generate 1.5 s of amplitude modulated (40 Hz) bandpass (300-700 Hz) correlated (0.8) noise with an ITD of 500 μs


```julia
noise_source = CorrelatedNoiseSource(Float64, sample_rate, audio_channels, 0.3, 0.8)
correlated_noise = read(noise_source, 1.5u"s")
filtered_noise = bandpass_filter(correlated_noise, 300u"Hz", 700u"Hz")
modulated_noise = amplitude_modulate(filtered_noise, 40u"Hz")
it = set_ITD(modulated_noise, -24)

time = 1:size(it, 1); time = time ./ sample_rate
a = plot(time, it, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, it, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (1000, 400))
```

![am_itd](examples/am_itd.png)


---------------------------------------------------------------------------------

Generate 6 s of a harmonic complex tone with 200 Hz harmonics

```julia
source = HarmonicComplex(Float64, 48000, collect(200:200:2400))
sound = read(source, 6u"s")
sound = amplitude_modulate(sound, 15u"Hz")
sound = sound .* 0.03
PlotSpectroTemporal(sound, frequency_limits = [0, 3000], time_limits = [0.135, 0.33], amplitude_limits = [-0.6, 0.6])
```


![HC](examples/harmonic-complex.png)
