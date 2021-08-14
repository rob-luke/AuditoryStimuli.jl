# Example: Interaural Time Delay Modulation

This stimuli has an ITD that is modulated from the left to right.
This stimulus is used to elicit an interaural time delay following response,
which has been related to spatial listening performance [1].

[1] Undurraga, J. A., Haywood, N. R., Marquardt, T., & McAlpine, D. (2016). Neural representation of interaural time differences in humans—An objective measure that matches behavioural performance. Journal of the Association for Research in Otolaryngology, 17(6), 591-607.


### Realtime Example

This example contains several processing steps and a dynamically changing pipeline.

A signal is generated which is identical in two channels.
This signal is then bandpass filtered between 300 and 700 Hz,
and is then modulated at 20 Hz.
At the minimum of each modulation the ITD is switched from left to right leading with a 48 sample delay.


```@example realtime
using AuditoryStimuli, Unitful, Plots, Pipe, DSP
default(size=(700, 300)) # hide
using DisplayAs # hide

# Specify the source, modifiers, and sink of our audio pipeline
source = CorrelatedNoiseSource(Float64, 48u"kHz", 2, 0.2, 1)
sink = DummySampleSink(Float64, 48u"kHz", 2)
am = AmplitudeModulation(20u"Hz")

# Design the filter
responsetype = Bandpass(300, 700; fs=48000)
designmethod = Butterworth(14)
zpg = digitalfilter(responsetype, designmethod)
f_left = DSP.Filters.DF2TFilter(zpg)
f_right = DSP.Filters.DF2TFilter(zpg)
bp = AuditoryStimuli.Filter([f_left, f_right])

itd_left = TimeDelay(2, 48, true)
itd_right = TimeDelay(1, 48, false)

# Run real time audio processing
for frame = 1:4

    @pipe read(source, 1/20u"s") |>
          modify(bp, _) |> modify(am, _) |>
          modify(itd_left, _) |> modify(itd_right, _) |>
          write(sink, _)

    # For each modulation cycle switch between left and right leading ITD
    itd_left.enable = !itd_left.enable
    itd_right.enable = !itd_right.enable
end

# Validate the audio pipeline output
plot(sink, label=["Left" "Right"])
current() |> DisplayAs.PNG # hide
```

In the figure above we observe that in the first and third modulation the signal is left leading, and that in the second and fourth cycle the signal is right leading.
