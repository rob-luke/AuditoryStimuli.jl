# Example: Bandpass Noise

This common stimulus is used for determining hearing thresholds.

In this example we geneate a bandpass noise signal.

### Realtime Example

In this example we process the audio in 10 millisecond frames.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = NoiseSource(Float64, 48u"kHz", 2, 0.2)
sink = DummySampleSink(Float64, 48u"kHz", 2)

# Design the filter
responsetype = Bandpass(300, 700; fs=48000)
designmethod = Butterworth(14)
zpg = digitalfilter(responsetype, designmethod)
f_left = DSP.Filters.DF2TFilter(zpg)
f_right = DSP.Filters.DF2TFilter(zpg)
bp = AuditoryStimuli.Filter([f_left, f_right])

# Run real time audio processing
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(bp, _) |> write(sink, _)
end

# Validate the audio pipeline output
PlotSpectroTemporal(sink, figure_size=(750, 400), frequency_limits = [0, 4000])
current() |> DisplayAs.PNG # hide
```


### Offline Example

It is also possible to generate the audio in an offline (all in one step) manner. This may be useful for creating wav files for use in simpler experiments.

```@example offline
using AuditoryStimuli, Unitful, Plots, DSP, WAV
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = NoiseSource(Float64, 48u"kHz", 2, 0.2)

# Design the filter
responsetype = Bandpass(500, 4000; fs=48000)
designmethod = Butterworth(4)
zpg = digitalfilter(responsetype, designmethod)
f_left = DSP.Filters.DF2TFilter(zpg)
f_right = DSP.Filters.DF2TFilter(zpg)
bp = AuditoryStimuli.Filter([f_left, f_right])

# Run real time audio processing
audio = read(source, 1.0u"s")
modulated_audio = modify(bp, audio)

# Write the audio to disk as a wav file
wavwrite(modulated_audio.data, "BP-noise.wav",Fs=48000)
```
