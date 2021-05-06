# Example: Interaural Time Delay

Stimuli with a delay applied to one ear causes the sound to be perceived
as coming from a different direction.
These stimuli are commonly used to investigate source localisation algorithms [1].

[1] Luke, R., & McAlpine, D. (2019, May). A spiking neural network approach to auditory source lateralisation. In ICASSP 2019-2019 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP) (pp. 1488-1492). IEEE.
Chicago	



### Realtime Example

In this example we apply a 48 sample delay to the second channel (right ear).
When presented over headphones this causes the sound to be perceived as arriving from the left,
as the sound arrives at the left ear first.


```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = CorrelatedNoiseSource(Float64, 48u"kHz", 2, 0.2, 1)
itd_left = TimeDelay(2, 48, true)
sink = DummySampleSink(Float64, 48u"kHz", 2)


# Run real time audio processing
for frame = 1:100

    @pipe read(source, 1/100u"s") |> modify(itd_left, _) |> write(sink, _)

end

# Validate the audio pipeline output
plot(sink, label=["Left" "Right"])
current() |> DisplayAs.PNG # hide
```

The stimulus output can be validated by observing that the peak in the cross correlation function occurs at 48 samples.

```@example realtime
using StatsBase

lags = round.(Int, -60:1:60)
plot(lags, crosscor(sink.buf[:, 1], sink.buf[:, 2], lags),
     label="", ylab="Cross Correlation", xlab="Lag (samples)")
current() |> DisplayAs.PNG # hide
```

