# Example: Signal and Noise

This example demonstrates how to produce a signal of interest
and an additive noise signal. The noise signal is only applied
during a specified time window.


### Realtime Example


```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = NoiseSource(Float64, 48u"kHz", 1, 1)
noisesource = NoiseSource(Float64, 48u"kHz", 1, 1)
sink = DummySampleSink(Float64, 48u"kHz", 1)
am = AmplitudeModulation(40u"Hz")

# Design the filter
responsetype = Bandpass(1500, 2500; fs=48000)
designmethod = Butterworth(14)
zpg = digitalfilter(responsetype, designmethod)
f_left = DSP.Filters.DF2TFilter(zpg)
bp = AuditoryStimuli.Filter([f_left])

# Run real time audio processing
for frame = 1:100
    
    # Generate the signal of interest
    output = @pipe read(source, 0.01u"s") |> modify(bp, _)  |> modify(am, _) 

    # During 0.3-0.7s apply a white noise
    if 30 < frame < 70
	output += @pipe read(noisesource, 0.01u"s") 
    end

    # Write the output to device
    write(sink, output)
end

# Validate the audio pipeline output
PlotSpectroTemporal(sink, figure_size=(750, 400), frequency_limits = [0, 4000])
current() |> DisplayAs.PNG # hide
```

