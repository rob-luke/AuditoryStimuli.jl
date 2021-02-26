# Realtime Audio Processing

Here we demonstrate how to stream audio and apply modifications to the signal.
We will vary the amplitude of the signal and apply a filter during a limited time window.

The real-time processing consist of a source, modifiers, and a sink.
Sources generate the raw signal.
Modifiers alter the signal they are applied to.
Sinks are a destination for the signals, typically a sound card, but in this example we use a buffer.

First we load the required packages and specify the sample rate and number of audio channels.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe

sample_rate = 48000
audio_channels = 2;
source_rms = 0.2
```


## Set up the signal pipeline components

Next we open a connection with a sink.
This would typically be a sound card, but that is not possible on a web site.
Instead, for this website example we use a dummy sink.

```@example realtime
sink = DummySampleSink(Float64, sample_rate, num_channels)

# But on a real system you would use something like
# a = PortAudio.devices()
# sink = PortAudioStream(a[3], 0, 2)
```

We also need a source.
Here we use a simple white noise source.

```@example realtime
source = NoiseSource(Float64, Fs, num_channels, source_rms)
```

And we will apply one signal modifier.
The first modifier adjusts the amplitude of the signal.
We want the signal to ramp from silent to full intensity,
so we set the initial value to 0.0 and the target value to 1.0,
and the maximum change per frame to 0.01.

```@example realtime
amp = Amplification(0,0, 1.0, 0.01)
```


## Run the real-time audio pipeline

We will now read from the noise source in 1/100th second frames.
This is then passed through the signal amplifier,
then sent to the sink.

```@example realtime
for frame = 1:300
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
```


## Verify the output

```@example realtime
plot(sink.buf)
```
