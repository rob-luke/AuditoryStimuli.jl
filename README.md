# AuditoryStimuli.jl goes beep and ssshhh

![Tests](https://github.com/rob-luke/AuditoryStimuli.jl/workflows/Tests/badge.svg)
[![codecov.io](http://codecov.io/github/rob-luke/AuditoryStimuli.jl/coverage.svg?branch=master)](http://codecov.io/github/rob-luke/AuditoryStimuli.jl?branch=master)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.03613/status.svg)](https://doi.org/10.21105/joss.03613)


Generate auditory stimuli for real-time applications.  Specifically, stimuli that are used in auditory research.


## Stimuli

This package provides low levels tools to build any stimulus.
It also provides high level convenience functions and examples for common stimuli such as:
* Amplitude modulated noise
* Harmonic stacks or harmonic complexes
* Binaural stimuli with user specified interaural correlation
* Frequency following response stimuli
* and more...


## Documentation

https://rob-luke.github.io/AuditoryStimuli.jl


## Community guidelines

I warmly welcome any contributions from the community.
This may take the form of feedback via the issues list,
bug reports (also via the issues list),
code submission (via pull requests).
Please feel free to suggest features, or additional stimuli you are interested in.
Or if you just want to show support, click the star button at the top of the page.


## Acknowledgements

This package is built on top of the excellent packages:
* [SampledSignals](https://github.com/JuliaAudio/SampledSignals.jl)
* [Unitful](https://github.com/ajkeller34/Unitful.jl)
* [Plots](https://github.com/JuliaPlots/Plots.jl)

If you use this package please cite:

```text
Luke, R., (2021). AuditoryStimuli.jl: A Julia package for generating real-time auditory stimuli.
Journal of Open Source Software, 6(65), 3613, https://doi.org/10.21105/joss.03613
```
