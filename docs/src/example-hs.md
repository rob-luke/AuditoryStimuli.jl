# Example: Harmonic Stack Complex

Harmonic stacks are often used to investigate pitch processing and streaming/grouping.
Harmonic complexes contain a set of frequency components which are harmonics.

In this example we generate a harmonic stack which is modulated at 15 Hz.

### Realtime Example

In this example we process the audio in 10 millisecond frames.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
stack_frequencies = 200:200:2400
source = SinusoidSource(Float64, 48u"kHz", stack_frequencies)
amp = Amplification(current=1/length(stack_frequencies),
                    target=1/length(stack_frequencies),
                    change_limit=1)
am = AmplitudeModulation(15u"Hz")
sink = DummySampleSink(Float64, 48u"kHz", 1)

# Run real time audio processing
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> modify(am, _) |> write(sink, _)
end

# Validate the audio pipeline output
PlotSpectroTemporal(sink, frequency_limits = [0, 3000], time_limits = [0.135, 0.33])
current() |> DisplayAs.PNG # hide
```



### Offline Example

It is also possible to generate the audio in an offline (all in one step) manner.
This may be useful for creating wav files for use in simpler experiments.

```@example offline
using AuditoryStimuli, Unitful, Plots, WAV
default(size=(700, 300)) # hide
using DisplayAs # hide

stack_frequencies = 200:200:2400
source = SinusoidSource(Float64, 48u"kHz", stack_frequencies)
am = AmplitudeModulation(15u"Hz")

audio = read(source, 1.0u"s") 
modulated_audio = modify(am, audio) 

# Write the audio to disk as a wav file
wavwrite(modulated_audio.data ./ length(stack_frequencies), "harmonic-stack.wav",Fs=48000)
```
