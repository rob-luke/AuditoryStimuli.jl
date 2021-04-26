# Realtime Audio Processing

This example demonstrates how to stream audio and apply real-time
signal processing to the signal.

Real-time processing consists of a source, zero or more modifiers, and a sink.
Sources generate the raw signal.
Modifiers alter the signal.
Sinks are a destination for the signals, typically a sound card, but in this example we use a buffer.

First the required packages are loaded and the sample rate and number of audio channels is specified.
This package makes extensive use of units to minimise the chance of coding mistakes,
below the sample rate is specified in the unit of kHz.

```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP

sample_rate = 48u"kHz"
audio_channels = 2;
source_rms = 0.2

default(size=(800, 300)) # hide
```


## Set up the signal pipeline components

First we need a source.
Here we use a simple white noise source and we specify
the type of data we want to work with (Floats),
the sample rate, number of channels, and the RMS of each channel.

```@example realtime
source = NoiseSource(Float64, sample_rate, audio_channels, source_rms)
nothing # hide
```

A sink is also required.
This would typically be a sound card, but that is not possible on a web site.
Instead, for this website example a dummy sink is used, which simply saves the sample to a buffer.

```@example realtime
sink = DummySampleSink(Float64, sample_rate, audio_channels)

# But on a real system you would use something like
# devices = PortAudio.devices()
# println(devices)
# sink = PortAudioStream(devices[3], sample_rate, audio_channels)
```

And we will apply one signal modifier.
This signal modifier simply adjusts the amplitude of the signal
with a linear scaling.
We specify the desired linear amplification to be 1.0, so no modification to the amplitude.
However, we do not want the signal to jump from silent to full intensity,
so we specify the current value of the amplitude as 0 (silent) and set the maximum increase per frame to be
0.05.
This will ramp the signal from silent to full intensity.

```@example realtime
amp = Amplification(current=0.0, target=1.0, change_limit=0.05)
nothing # hide
```


## Run the real-time audio pipeline

Audio is typically processed in small chunks of samples called frames.
Here we request a frame from the noise source with length 1/100th of a second,
or 480 samples.
This is then passed through the signal amplifier,
then sent to the sink.

```@example realtime
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> write(sink, _)
end
```


## Verify processing was correctly applied

```@example realtime
plot(sink)
```


## Apply a filter modifier

A filter can also be applied to the data as a modifier.
The filter also maintains its state, so can be used in real time processing.
Below a bandpass filter is designed, for more details on filter design
using the DSP package see [this documentation](https://docs.juliadsp.org/stable/filters/).



```@example realtime
responsetype = Bandpass(500, 4000; fs=48000)
designmethod = Butterworth(4)
zpg = digitalfilter(responsetype, designmethod)
nothing # hide
```

Once the filter is specified as a zero pole gain representation
two filters are instansiated using this specification.
A filter must be generated for each channel of audio.
These DSP.Filters are then passed in to the AuditoryStimuli filter object for further use.


```@example realtime
f_left = DSP.Filters.DF2TFilter(zpg)
f_right = DSP.Filters.DF2TFilter(zpg)
bandpass = AuditoryStimuli.Filter([f_left, f_right])
nothing # hide
```

Once the filters are designed and placed in an AuditoryStimule.Filter object they can
be used just like any other modifier.
Below the filer is applied to 1 second of audio in 1/100th second frames.

```@example realtime
for frame = 1:100
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> modify(bandpass, _) |> write(sink, _)
end
```

## Modifying modifier parameters

The parameters of modifiers can be varied at any time.
Below the target amplification is set to zero to ramp off the signal.

```@example realtime
setproperty!(amp, :target, 0.0)
for frame = 1:20
    @pipe read(source, 0.01u"s") |> modify(amp, _) |> modify(bandpass, _) |> write(sink, _)
end
 nothing # hide
```

## Verify output

The entire signal (both the amplification, then the filtering) can be viewed
using the convenience plotting function below.
We observe that the signal is ramped on due to the amplification modifier.
We can then see that at 1 second the spectral content of the signal was modified.
And finally the signal is ramped off.


```@example realtime
PlotSpectroTemporal(sink, figure_size=(800, 400), frequency_limits = [0, 8000])
```

## Other examples

Modulation 
```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP

sample_rate = 48u"kHz"
audio_channels = 2;
source_rms = 0.2

source = NoiseSource(Float64, sample_rate, audio_channels, source_rms)
sink = DummySampleSink(Float64, sample_rate, audio_channels)
am = AmplitudeModulation(4, π, 1.5)

for frame = 1:300
    @pipe read(source, 0.01u"s") |> modify(am, _) |> write(sink, _)
end

plot(sink)

```



## Other tips

This example demonstrates the basics of real-time signal processing with this package.
For a real application the following considerations may be required:
* Running the audio stream in its own thread so you can process user input or run other code in parallel.
    This is easily accomplised using `@spawn`, see: [example](https://github.com/rob-luke/AuditoryStimuli.jl/pull/21/files#diff-74e065fd2058f67e28f1771eb9cd167dcab282308ed048ab5997f8c1e928b4bfR79)
* Enable or disable processing rather than modifying the pipeline.
    Each modifier has an enable flag so that it can be disabled,
    when disabled the signal is simply passed through and not modified.
