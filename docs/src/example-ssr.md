# Example: Amplitude Modulated Noise

In this example we geneate a white noise signal which is modualted at 40 Hz.
These signals are commonly used to ellicit auditory steady-state responses [1].

[1] Luke, R., Van Deun, L., Hofmann, M., Van Wieringen, A., & Wouters, J. (2015). Assessing temporal modulation sensitivity using electrically evoked auditory steady state responses. Hearing research, 324, 37-45.


### Realtime Example

In this example we process the audio in 10 millisecond frames.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = NoiseSource(Float64, 48u"kHz", 2, 0.2)
sink = DummySampleSink(Float64, 48u"kHz", 2)
am = AmplitudeModulation(40u"Hz")

# Run real time audio processing
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(am, _) |> write(sink, _)
end

# Validate the audio pipeline output
plot(sink, label=["Left" "Right"])
current() |> DisplayAs.PNG # hide
```


### Offline Example

It is also possible to generate the audio in an offline (all in one step) manner. This may be useful for creating wav files for use in simpler experiments.

```@example offline
using AuditoryStimuli, Unitful, Plots, WAV
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = NoiseSource(Float64, 48u"kHz", 2, 0.2)
am = AmplitudeModulation(40)

# Run real time audio processing
audio = read(source, 1.0u"s")
modulated_audio = modify(am, audio)

# Write the audio to disk as a wav file
wavwrite(modulated_audio.data, "AM-noise.wav",Fs=48000)
```
