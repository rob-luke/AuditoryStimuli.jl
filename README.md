# AuditoryStimuli

[![Build Status](https://travis-ci.org/rob-luke/AuditoryStimuli.jl.svg?branch=master)](https://travis-ci.org/rob-luke/AuditoryStimuli.jl)
[![codecov.io](http://codecov.io/github/rob-luke/AuditoryStimuli.jl/coverage.svg?branch=master)](http://codecov.io/github/rob-luke/AuditoryStimuli.jl?branch=master)

Generate common auditory stimuli

## Installation

```julia
Pkg.clone('https://github.com/rob-luke/AuditoryStimuli.jl.git')
```


## Coming soon

Examples from research papers


## Example

```julia
time = 0:1/48000:1
cn = correlated_noise(length(time), 2, 1)
bn = bandpass_noise(cn, 300, 700, 48000)
an = amplitude_modulate(bn, 40, 48000)
im = ITD_modulate(an, 2, 24, -24, 48000)

a = plot(time, im, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, im, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (1000, 400))
```

![am_itd](examples/am_itd.png)