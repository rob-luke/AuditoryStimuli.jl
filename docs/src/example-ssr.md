# Realtime Audio Signal Processing

### Amplitude modulated noise

Create amplitude modulated white noise, with 4 Hz modulation rate. 

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(800, 300)) # hide

source = NoiseSource(Float64, 48u"kHz", 2, 0.2)
sink = DummySampleSink(Float64, 48u"kHz", 2)
am = AmplitudeModulation(40)

for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(am, _) |> write(sink, _)
end

plot(sink)
```
