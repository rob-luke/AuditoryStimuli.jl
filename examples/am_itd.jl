using Plots
using AuditoryStimuli

time = 0:1/48000:1
cn = correlated_noise(length(time), 2, 1)
bn = bandpass_noise(cn, 300, 700, 48000)
an = amplitude_modulate(bn, 40, 48000)
it = set_ITD(an, -24)

a = plot(time, it, lab = "", xlab = "Time (s)", ylab = "Amplitude", xlims = (0.0, 0.5))
b = plot(time, it, lab = map(string,[:Left :Right]), xlab = "Time (s)", ylab = "", xlims = (0.025, 0.05))
plot(a, b, size = (1000, 400))
savefig("examples/am_itd.png")