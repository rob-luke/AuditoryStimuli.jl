# Realtime Audio Processing

This example demonstrates how to stream audio and apply real-time
signal processing to the signal.

Real-time processing consist of a source, zero or more modifiers, and a sink.
Sources generate the raw signal.
Modifiers alter the signal.
Sinks are a destination for the signals, typically a sound card, but in this example we use a buffer.

First the required packages are loaded and the sample rate and number of audio channels is specified.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe

sample_rate = 48000
audio_channels = 2;
source_rms = 0.2

default(size=(800, 300)) # hide
```


## Set up the signal pipeline components

First a sink is generated.
This would typically be a sound card, but that is not possible on a web site.
Instead, for this website example a dummy sink is used, which simply saves the sample to a buffer.

```@example realtime
sink = DummySampleSink(Float64, sample_rate, audio_channels)

# But on a real system you would use something like
# a = PortAudio.devices()
# sink = PortAudioStream(a[3], 0, 2)
```

We also need a source.
Here we use a simple white noise source.

```@example realtime
source = NoiseSource(Float64, sample_rate, audio_channels, source_rms)
nothing # hide
```

And we will apply one signal modifier.
The first modifier adjusts the amplitude of the signal.
We want the signal to ramp from silent to full intensity,
so we set the initial value to 0.0 and the target value to 1.0,
and the maximum change per frame to 0.01.

```@example realtime
amp = Amplification(1.0, 0.0, 0.05)
nothing # hide
```


## Run the real-time audio pipeline

We will now read from the noise source in 1/100th second frames.
This is then passed through the signal amplifier,
then sent to the sink.

```@example realtime
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
```


## Verify the output

```@example realtime
plot(sink.buf)
```

Next we can modify the amplification 

```@example realtime
setproperty!(amp, :target_amplification, 0.5)
nothing # hide
```

and push another 2 seconds through
the pipeline.


```@example realtime
for frame = 1:50
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
setproperty!(amp, :target_amplification, 1.0)
for frame = 1:50
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
setproperty!(amp, :target_amplification, 0.0)
for frame = 1:50
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
```

Next


```@example realtime
plot(sink.buf)
```
