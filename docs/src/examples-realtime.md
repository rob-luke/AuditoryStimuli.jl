# Realtime Audio Processing

Here we demonstrate how to stream audio and apply modifications to the signal

```@example realtime
using AuditoryStimuli, Unitful, Plots
using Random; Random.seed!(0)

sample_rate = 48000
audio_channels = 2;
```
