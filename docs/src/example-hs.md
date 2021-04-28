# Realtime Audio Signal Processing

### Harmonic Stack Complex

Create amplitude modulated white noise, with 4 Hz modulation rate. 

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

source = HarmonicComplex(Float64, 48000, collect(200:200:2400))
am = AmplitudeModulation(15)
sink = DummySampleSink(Float64, 48u"kHz", 2)

for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(am, _) |> write(sink, _)
end

PlotSpectroTemporal(sink, frequency_limits = [0, 3000], time_limits = [0.135, 0.33], figure_size=(700, 350))
current() |> DisplayAs.PNG # hide
```
