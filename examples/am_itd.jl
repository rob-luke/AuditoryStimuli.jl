using Plots
using AuditoryStimuli

time = 0:1/48000:1
cn = correlated_noise(length(time), 2, 1)
bn = bandpass_noise(cn, 300, 700, 48000)
mn = amplitude_modulate(bn, 40, 48000)
im = ITD_modulate(mn, 2, 24, -24, 48000)
of = set_RMS(im, 0.1)

pyplot()

a = plot(time, of, lab = "", xlab = "Time (s)", ylab = "Amplitude")
b = plot(time, of, lab = map(string,[:left :right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (800, 400))
