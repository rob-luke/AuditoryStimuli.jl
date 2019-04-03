using AuditoryStimuli
using Test
using DSP
using StatsBase
using Statistics
using Logging
using Plots
using Unitful
using SampledSignals
using Images

Fs = 48000

@testset "Auditory Stimuli" begin


    @testset "Generator Functions" begin
    # ==================================

        @testset "SampledSignals" begin

            @testset "NoiseSource generator" begin

                source = NoiseSource(Float64, 48000, 2)
                a = read(source, 48000)
                @test size(a) == (48000, 2)
                @test std(a) ≈ 1 atol = 0.01

                for deviation = 0.1:0.1:1.3
                    source = NoiseSource(Float64, 48000, 1, deviation)
                    a = read(source, 48000*3)
                    @test std(a) ≈ deviation atol = 0.01
                end
            end

            @testset "CorrelatedNoiseSource generator" begin

                source = CorrelatedNoiseSource(Float64, 48000, 2, 1, 0.1)
                a = read(source, 48000)
                @test size(a) == (48000, 2)
                @test std(a) ≈ 1 atol = 0.01

                for correlation = 0:0.1:1
                    source = CorrelatedNoiseSource(Float64, Fs, 2, 0.3, correlation)
                    cn = read(source, Fs * 30)
                    @test cor(cn)[1, 2] ≈ correlation atol=0.01
                end

                for deviation = 0.1:0.1:1.3
                    for correlation = 0.0:0.1:0.9
                        source = CorrelatedNoiseSource(Float64, 48000, 2, deviation, correlation)
                        a = read(source, 48000)
                        @test std(a) ≈ deviation atol = 0.025
                        @test cor(a.data)[2, 1] ≈ correlation atol = 0.025
                    end
                end
            end

            @testset "Harmonic Complex" begin

                source = HarmonicComplex(Float64, 48000, 2000)
                a = read(source, 48000)
                @test size(a) == (48000, 1)


                freqs = collect(200:200:2400.0)
                source = HarmonicComplex(Float64, 48000, freqs)
                a = read(source, 48000)
                b = welch_pgram(vec(a.data), fs=a.samplerate)
                maxs_cart = findlocalmaxima(power(b))
                maxs = [idx[1] for idx in maxs_cart]
                maxs = maxs[power(b)[maxs] .> 0.02]
                @test freq(b)[maxs] == freqs

            end

        end

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

        end
    end
end
