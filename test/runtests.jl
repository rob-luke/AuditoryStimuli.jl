using AuditoryStimuli
using Test
using DSP
using StatsBase
using Statistics
using Logging
using Plots
using Unitful
using SampledSignals
using Pipe
using Images

Fs = 48000


@testset "Offline Stimuli" begin


    @testset "Generator Functions" begin
    # ==================================


        @testset "One hit signal generation" begin

            @testset "Bandpass Noise" begin

                # Test different constructors
                bn = bandpass_noise(Fs * 30, 2, 300, 700, Fs)

                # Test data is actuall filtered
                for lower_bound = 500:500:1500
                    for upper_bound = 2000:500:3000

                        bn = bandpass_noise(Fs * 30, 2, lower_bound, upper_bound, Fs)
                        @test size(bn, 1) == Fs * 30
                        spec = welch_pgram(bn[:, 1], fs=Fs)

                        val, idx_lb = findmin(abs.(freq(spec) .- lower_bound))
                        val, idx_bl = findmin(abs.(freq(spec) .- (lower_bound - 250)))
                        @test (amp2db(power(spec)[idx_lb]) - amp2db(power(spec)[idx_bl])) > 10

                        val, idx_ub = findmin(abs.(freq(spec) .- upper_bound))
                        val, idx_bu = findmin(abs.(freq(spec) .- (upper_bound + 250)))
                        @test (amp2db(power(spec)[idx_ub]) - amp2db(power(spec)[idx_bu])) > 10
                    end
                end
            end
        end


    end

    @testset "Modifier Functions" begin
    # ==================================

        @testset "Filter Signals" begin

            @testset "Bandpass Butterworth" begin

                @testset "Abstract Arrays" begin

                    # Test data is actuall filtered
                    for lower_bound = 500:500:1500
                        for upper_bound = 2000:500:3000

                            x = randn(Fs*30, 2)
                            bn = bandpass_filter(x, lower_bound, upper_bound, Fs)

                            @test size(bn, 1) == Fs * 30
                            @test size(bn, 2) == 2

                            for channel = 1:2
                                spec = welch_pgram(bn[:, channel], fs=Fs)

                                val, idx_lb = findmin(abs.(freq(spec) .- lower_bound))
                                val, idx_bl = findmin(abs.(freq(spec) .- (lower_bound - 250)))
                                @test (amp2db(power(spec)[idx_lb]) - amp2db(power(spec)[idx_bl])) > 10

                                val, idx_ub = findmin(abs.(freq(spec) .- upper_bound))
                                val, idx_bu = findmin(abs.(freq(spec) .- (upper_bound + 250)))
                                @test (amp2db(power(spec)[idx_ub]) - amp2db(power(spec)[idx_bu])) > 10
                            end
                        end
                    end
                end


                @testset "Sampled Signals" begin

                    source = CorrelatedNoiseSource(Float64, 48000, 2, 1, 0.1)
                    a = read(source, 48000)
                    b = bandpass_filter(a, 300u"Hz", 700u"Hz")

                    @test typeof(b) == typeof(a)
                    @test typeof(b) == SampleBuf{Float64,2}

                end

            end

        end


        @testset "Modulate Signals" begin

            @testset "Amplitude Modulation" begin

                @testset "Abstract Arrays" begin

                    for modulation_frequency = 1:1:10
                        x = randn(Fs, 1)
                        @test_nowarn amplitude_modulate(x, modulation_frequency, Fs)
                    end

                    for modulation_frequency = 1.3:1:10
                        x = randn(Fs, 1)
                        amplitude_modulate(x, modulation_frequency, Fs)
                        @test_logs (:warn, "Not a complete modulation") amplitude_modulate(x, modulation_frequency, Fs)
                    end
                end


                @testset "Sampled Signals" begin

                    source = CorrelatedNoiseSource(Float64, 48000, 2, 1, 0.1)
                    a = read(source, 48000)
                    b = amplitude_modulate(a, 20u"Hz")

                    @test typeof(b) == typeof(a)
                    @test typeof(b) == SampleBuf{Float64,2}

                end

            end


            @testset "ITD Modulation" begin

                @testset "Abstract Arrays" begin

                    source = CorrelatedNoiseSource(Float64, Fs, 2, 0.3, 0.99)
                    cn = read(source, Fs * 1)
                    bn = bandpass_filter(cn, 300, 700, Fs)
                    mn = amplitude_modulate(bn, 40, Fs)
                    im = ITD_modulate(mn, 8, 24, -24, Fs)

                    source = CorrelatedNoiseSource(Float64, Fs, 2, 0.3, 0.99)
                    cn = read(source, Fs * 1)
                    bn = bandpass_filter(cn, 300, 700, Fs)
                    mn = amplitude_modulate(bn, 40, Fs)
                    im = ITD_modulate(mn, 8, 48, -48, Fs)
                end
            end

        end

        @testset "RMS" begin

            @testset "Abstract Arrays" begin

                for desired_rms = 01:0.1:1
                    bn = bandpass_noise(Fs * 30, 2, 300, 700, Fs)
                    bn = set_RMS(bn, desired_rms)
                    @test rms(bn) ≈ desired_rms
                end
            end

            @testset "Sampled Signals" begin

                for desired_rms = 01:0.1:1
                    source = CorrelatedNoiseSource(Float64, 48000, 2, 1, 0.5)
                    bn = read(source, Fs * 30)
                    bn = set_RMS(bn, desired_rms)
                    @test rms(bn) ≈ desired_rms
                end
            end

        end


        @testset "Ramps" begin

            @testset "Ramp on" begin

                for ramp_length = [1, 2]
                    bn = bandpass_noise(Fs * 5, 2, 300, 700, Fs)
                    bn = ramp_on(bn, Fs * ramp_length)
                    @test rms(bn[1:Fs, :]) < rms(bn[2*Fs:3*Fs, :])
                end
            end

            @testset "Ramp off" begin

                for ramp_length = [1, 2]
                    bn = bandpass_noise(Fs * 5, 2, 300, 700, Fs)
                    bn = ramp_off(bn, Fs * ramp_length)
                    @test rms(bn[end-Fs:end, :]) < rms(bn[2*Fs:3*Fs, :])
                end
            end
        end

        @testset "ITD" begin

            for desired_itd = -100:10:100

                source = CorrelatedNoiseSource(Float64, Fs, 2, 0.3, 0.9)
                cn = read(source, Fs * 5)
                bn = bandpass_filter(cn, 300, 700, Fs)
                bn = set_ITD(bn, desired_itd)
                lags = round.(Int, -150:1:150)
                c = crosscor(bn[:, 2], bn[:, 1], lags)
                x, idx = findmax(c)
                @test lags[idx] == desired_itd
            end
        end

    end




    @testset "Plotting" begin
    # =======================

        @testset "SpectroTempral" begin

        source = CorrelatedNoiseSource(Float64, Fs, 2, 0.3, 0.99)
        cn = read(source, Fs * 1)
        bn = bandpass_filter(cn, 300, 700, Fs)
        mn = amplitude_modulate(bn, 40, Fs)
        im = ITD_modulate(mn, 8, 24, -24, Fs)
        p = PlotSpectroTemporal(im, 48000)
        @test isa(p, Plots.Plot) == true

        source = NoiseSource(Float64, 48000, 2, 0.1)
        sink = DummySampleSink(Float64, 48000, 2)
        @pipe read(source, 3.0u"s"/frames) |>  write(sink, _)
        p = PlotSpectroTemporal(sink)
        @test isa(p, Plots.Plot) == true
        p = plot(sink)
        @test isa(p, Plots.Plot) == true

        end
    end
end


# =======================
# Stream Processing
# =======================


@testset "Online Stimuli" begin

    @testset "Generators" begin

        @testset "NoiseSource generator" begin

            # Test instansiation
            source = NoiseSource(Float64, 48.0u"kHz", 2)
            @test source.samplerate == 48000
            @test source.samplerate == samplerate(source)

            source = NoiseSource(Float64, 48u"kHz", 2)
            @test source.samplerate == 48000

            source = NoiseSource(Float64, 48000u"Hz", 2)
            @test source.samplerate == 48000

            source = NoiseSource(Float64, 48000.1u"Hz", 2)
            @test source.samplerate == 48000.1

            source = NoiseSource(Float64, 44100, 1)
            @test source.samplerate == 44100

            source = NoiseSource(Float64, 48000, 2)
            @test source.samplerate == 48000

            # Test read
            a = read(source, 48000)
            @test size(a) == (48000, 2)
            @test std(a) ≈ 1 atol = 0.01

            a = read(source, 1u"s")
            @test size(a) == (48000, 2)
            @test std(a) ≈ 1 atol = 0.01

            # Test result
            for deviation = 0.1:0.1:1.3
                source = NoiseSource(Float64, 48000, 1, deviation)
                a = read(source, 48000*3)
                @test std(a) ≈ deviation atol = 0.01
            end
        end


        @testset "CorrelatedNoiseSource generator" begin

            # Test instansiation
            source = CorrelatedNoiseSource(Float64, 48.0u"kHz", 2, 1, 0.1)
            @test source.samplerate == 48000
            @test source.samplerate == samplerate(source)

            source = CorrelatedNoiseSource(Float64, 48u"kHz", 2, 1, 1)
            @test source.samplerate == 48000

            source = CorrelatedNoiseSource(Float64, 46u"Hz", 2, 1, 1)
            @test source.samplerate == 46

            source = CorrelatedNoiseSource(Float64, 44100.0u"Hz", 2, 1, 1)
            @test source.samplerate == 44100

            # Test read
            source = CorrelatedNoiseSource(Float64, 48000, 2, 1, 0.1)
            a = read(source, 48000)
            @test size(a) == (48000, 2)
            @test std(a) ≈ 1 atol = 0.01

            # Test behaviour
            for deviation = 0.1:0.2:1.3
                for correlation = 0.0:0.2:1
                    source = CorrelatedNoiseSource(Float64, 48000, 2, deviation, correlation)
                    a = read(source, 3u"s")
                    @test std(a) ≈ deviation atol = 0.025
                    @test cor(a.data)[2, 1] ≈ correlation atol = 0.025
                    @test interaural_coherence(a.data) ≈ correlation atol = 0.025
                end
            end
        end

        @testset "Harmonic Complex" begin

            # Test instansiation
            source = SinusoidSource(Float64, 48000u"Hz", 2)
            @test source.samplerate == 48000
            source = SinusoidSource(Float64, 48000.7u"Hz", [100, 324, 55, 999])
            @test source.samplerate == 48000.7
            source = SinusoidSource(Float64, 48000, 300:300:3000)

            source = SinusoidSource(Float64, 48000, 2000)
            a = read(source, 48000)
            @test size(a) == (48000, 1)


            freqs = collect(200:200:2400.0)
            source = SinusoidSource(Float64, 48000, freqs)
            a = read(source, 48000)
            b = welch_pgram(vec(a.data), fs=a.samplerate)
            maxs_cart = Images.findlocalmaxima(power(b))
            maxs = [idx[1] for idx in maxs_cart]
            maxs = maxs[power(b)[maxs] .> 0.02]
            @test freq(b)[maxs] == freqs

        end

    end

    @testset "Modifiers" begin

        @testset "Input / Output" begin

            desired_rms = 0.3
            for num_channels = 1:2
                for frames = [100, 50, 20]
                    source = NoiseSource(Float64, Fs, num_channels, desired_rms)
                    sink = DummySampleSink(Float64, 48000, num_channels)
                    for idx = 1:frames
                        @pipe read(source, 1.0u"s"/frames) |>  write(sink, _)
                    end
                    @test size(sink.buf, 1) == 48000
                    @test size(sink.buf, 2) == num_channels
                    @test rms(sink.buf) ≈ desired_rms  atol = 0.01
                end
            end

            source = NoiseSource(Float64, 96000u"Hz", 2, 0.1)
            @test source.samplerate == 96000
            source = NoiseSource(Float64, 96u"kHz", 2)
            @test source.samplerate == 96000
            sink = DummySampleSink(Float64, 48000u"Hz", 3)
            @test sink.samplerate == 48000
            sink = DummySampleSink(Float64, 48000.0u"Hz", 3)
            @test sink.samplerate == 48000
            sink = DummySampleSink(Float64, 48u"kHz", 4)
            @test sink.samplerate == 48000
            sink = DummySampleSink(Float64, 48.0u"kHz", 4)
            @test sink.samplerate == 48000
        end

        @testset "Amplification" begin

            # Test different ways of instanciating the modifier
            @test Amplification().target == 0
            @test Amplification().current == 0
            @test Amplification().change_limit == Inf
            @test Amplification().enable == true
            @test Amplification(1).target == 1.0
            @test Amplification(1, 3).target == 1.0
            @test Amplification(1, 3).current == 3.0
            @test Amplification(1, 3, 4, false).change_limit == 4.0
            @test Amplification(1, 3, 4, false).enable == false
            @test Amplification(target=3).target == 3
            @test Amplification(current=3).current == 3
            @test Amplification(change_limit=3).change_limit == 3
            @test Amplification(enable=false).enable == false
            @test Amplification(enable=false, current=2).enable == false
            @test Amplification(enable=false, current=2).current == 2

            # Ensure disabled does nothing
            source = NoiseSource(Float64, 48000, 2, 1)
            sink = DummySampleSink(Float64, 48000, 2)
            amp = Amplification(2, 3, 0.5, false)
            data = read(source, 1u"s")
            @pipe data |> modify(amp, _) |>  write(sink, _)
            @test sink.buf == data.data


            desired_rms = 0.3
            amp_mod = 0.1
            num_channels = 1

            @testset "Static" begin

                source = NoiseSource(Float64, Fs, num_channels, desired_rms)
                sink = DummySampleSink(Float64, 48000, num_channels)
                amp = Amplification(amp_mod, amp_mod, 0.005)

                for idx = 1:200
                    @pipe read(source, 0.01u"s") |> modify(amp, _) |>  write(sink, _)
                end
                @test size(sink.buf, 1) == 96000
                @test size(sink.buf, 2) == num_channels
                @test rms(sink.buf) ≈ desired_rms * amp_mod  atol = 0.01
            end

            @testset "Dynamic" begin

                source = NoiseSource(Float64, Fs, num_channels, desired_rms)
                sink = DummySampleSink(Float64, 48000, num_channels)
                amp = Amplification(target=amp_mod, current=amp_mod, change_limit=0.5)

                for idx = 1:200
                    if idx == 100
                        setproperty!(amp, :target, 1.0)
                    end
                    @pipe read(source, 0.01u"s") |> modify(amp, _) |>  write(sink, _)
                end
                @test size(sink.buf, 1) == 96000
                @test size(sink.buf, 2) == num_channels
                @test rms(sink.buf[1:48000]) ≈ desired_rms * amp_mod  atol = 0.01
                @test rms(sink.buf[48000:96000]) ≈ desired_rms atol = 0.01
            end
        end

        @testset "Filtering" begin

            desired_rms = 0.3
            amp_mod = 0.1
            for num_channels = 1:2

                @testset "Channels: $num_channels" begin

                    source = NoiseSource(Float64, Fs, num_channels, desired_rms)
                    sink = DummySampleSink(Float64, Fs, num_channels)

                    lower_bound = 1000
                    upper_bound = 4000

                    responsetype = Bandpass(lower_bound, upper_bound; fs=Fs)
                    designmethod = Butterworth(14)
                    zpg = digitalfilter(responsetype, designmethod)
                    f1 = DSP.Filters.DF2TFilter(zpg)
                    f2 = DSP.Filters.DF2TFilter(zpg)
                    filters = [f1]
                    if num_channels == 2; filters = [filters[1], f2]; end
                    bandpass = AuditoryStimuli.Filter(filters)

                    for idx = 1:500
                        @pipe read(source, 0.01u"s") |> modify(bandpass, _) |>  write(sink, _)
                    end
                    @test size(sink.buf, 1) == 48000 * 5
                    @test size(sink.buf, 2) == num_channels

                    for chan = 1:num_channels

                        spec = welch_pgram(sink.buf[:, chan], 12000, fs=Fs)

                        val, idx_lb = findmin(abs.(freq(spec) .- lower_bound))
                        val, idx_bl = findmin(abs.(freq(spec) .- (lower_bound - 500)))
                        @test (amp2db(power(spec)[idx_lb]) - amp2db(power(spec)[idx_bl])) > 10

                        val, idx_ub = findmin(abs.(freq(spec) .- upper_bound))
                        val, idx_bu = findmin(abs.(freq(spec) .- (upper_bound + 500)))
                        @test (amp2db(power(spec)[idx_ub]) - amp2db(power(spec)[idx_bu])) > 10
                    end

                    # Test turning filter off
                    setproperty!(bandpass, :enable, false)

                    for idx = 1:1500
                        @pipe read(source, 0.01u"s") |> modify(bandpass, _) |>  write(sink, _)
                    end
                    @test size(sink.buf, 1) == 48000 * 20
                    @test size(sink.buf, 2) == num_channels

                    for chan = 1:num_channels

                        spec = welch_pgram(sink.buf[48000* 5:48000*20, chan], 12000, fs=Fs)

                        val, idx_lb = findmin(abs.(freq(spec) .- lower_bound))
                        val, idx_bl = findmin(abs.(freq(spec) .- (lower_bound - 500)))
                        @test (amp2db(power(spec)[idx_lb]) - amp2db(power(spec)[idx_bl])) < 6

                        val, idx_ub = findmin(abs.(freq(spec) .- upper_bound))
                        val, idx_bu = findmin(abs.(freq(spec) .- (upper_bound + 500)))
                        @test (amp2db(power(spec)[idx_ub]) - amp2db(power(spec)[idx_bu])) < 6
                    end
                end
            end
        end

        @testset "Amplitude Modulation" begin

            for num_channels = 1:5

                @testset "Channels: $num_channels" begin

                    source = NoiseSource(Float64, Fs, num_channels)
                    sink = DummySampleSink(Float64, 48000, num_channels)
                    am = AmplitudeModulation(10u"Hz")

                    for idx = 1:10
                        @pipe read(source, 0.01u"s") |> modify(am, _) |>  write(sink, _)
                    end
                    @test size(sink.buf, 1) == 4800
                    @test size(sink.buf, 2) == num_channels

                    start_mod = Statistics.sum(abs.(sink.buf[1:1000, :]))
                    mid_mod = Statistics.sum(abs.(sink.buf[2000:3000, :]))
                    end_mod = Statistics.sum(abs.(sink.buf[3800:4800, :]))

                    @test mid_mod > start_mod
                    @test mid_mod > end_mod
                
                    # Test different ways of instanciating the modifier
                    @test AmplitudeModulation(1u"MHz").rate == 1000000u"Hz"
                    @test AmplitudeModulation(1u"kHz").rate == 1000u"Hz"
                    @test AmplitudeModulation(1u"mHz").rate == 0.001u"Hz"
                    @test AmplitudeModulation(10u"Hz").rate == 10u"Hz"
                    @test AmplitudeModulation(1.0u"Hz").rate == 1u"Hz"
                    @test AmplitudeModulation(10u"Hz", 0.0).rate == 10u"Hz"
                    @test AmplitudeModulation(10.3u"Hz", 0.0).rate == 10.3u"Hz"
                    @test AmplitudeModulation(10u"Hz", π).rate == 10u"Hz"
                    @test AmplitudeModulation(10u"Hz", π, 0.0).rate == 10u"Hz"
                    @test AmplitudeModulation(10u"Hz", π, 0.5).rate == 10u"Hz"
                    @test AmplitudeModulation(10.8u"Hz", π, 0.5).rate == 10.8u"Hz"
                    @test AmplitudeModulation(1.0u"kHz", π, 1.5).rate == 1000u"Hz"
                    @test AmplitudeModulation(1.0u"kHz", π, 1.5, false).enable == false
                    @test AmplitudeModulation(10u"Hz", π, 1.5).depth == 1.5
                    @test AmplitudeModulation(rate=3u"Hz").rate == 3.0u"Hz"
                    @test AmplitudeModulation(phase=3).phase == 3
                    @test AmplitudeModulation(depth=0.5).depth == 0.5

                    # Test defaults
                    @test AmplitudeModulation().rate == 0u"Hz"
                    @test AmplitudeModulation().phase == π
                    @test AmplitudeModulation().depth == 1
                    @test AmplitudeModulation().enable == true
                    @test AmplitudeModulation().time == 0

                    # Test bad instansiation
                    @test_logs (:error, "You must use units for modulation rate.")  AmplitudeModulation(33)

                    # Ensure disabled does nothing
                    sink = DummySampleSink(Float64, 48000, num_channels)
                    amp = AmplitudeModulation(enable=false)
                    data = read(source, 1u"s")
                    @pipe data |> modify(amp, _) |>  write(sink, _)
                    @test sink.buf == data.data

                end
            end
        end

        @testset "ITD" begin

            # Test instansiation
            itd = TimeDelay()
            itd = TimeDelay(2)
            itd = TimeDelay(1, 22)
            itd = TimeDelay(1, 22, false)
            itd = TimeDelay(1, 22, false, ones(22, 1))
            itd = TimeDelay(delay=33, buffer=zeros(33, 1))
            itd = TimeDelay(channel=33)
            itd = TimeDelay(enable=false, channel=3)

            # Test correct behaiour
            for desired_itd = -100:10:100

                source = CorrelatedNoiseSource(Float64, 48000, 2, 0.3, 1)
                if desired_itd >= 0
                    itd = TimeDelay(2, desired_itd)
                else
                    itd = TimeDelay(1, -desired_itd)
                end
                sink = DummySampleSink(Float64, 48000, 2)
                
                for idx = 1:10
                    @pipe read(source, 0.1u"s") |> modify(itd, _) |>  write(sink, _)
                end

                lags = round.(Int, -150:1:150)
                c = crosscor(sink.buf[:, 1], sink.buf[:, 2], lags)
                x, idx = findmax(c)
                @test lags[idx] == desired_itd
            end
        end
    end
end


@testset "Signal Metrics" begin

    @testset "Interaural Coherence" begin

        for correlation = 0.2:0.2:0.8
            source = CorrelatedNoiseSource(Float64, 48000, 2, 0.4, correlation)
            a = read(source, 3u"s")
            @test interaural_coherence(a.data) ≈ correlation atol = 0.025
            @test interaural_coherence(a.data, lags=100) ≈ correlation atol = 0.025
        end
    end
end
