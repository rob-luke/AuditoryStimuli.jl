using AuditoryStimuli
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

using Plots
using DSP

Fs = 48000

@testset "Generator Functions" begin

    @testset "Correlated Noise" begin

        for correlation = 0:0.1:1
            cn = correlated_noise(Fs * 30, 2, correlation)
            @test cor(cn)[1, 2] ≈ correlation atol=0.01
        end
    end


    @testset "Bandpass Noise" begin

        # Test different constructors
        bn = bandpass_noise(Fs * 30, 2, 300, 700, Fs)
        bn = bandpass_noise(randn(Fs*30, 2), 300, 700, Fs)

        # Test data is actuall filtered
        for lower_bound = 500:500:1500
            for upper_bound = 2000:500:3000

                bn = bandpass_noise(Fs * 30, 2, lower_bound, upper_bound, Fs)
                @test size(bn, 1) == Fs * 30
                spec = welch_pgram(bn[:, 1], fs=Fs)

                val, idx_lb = findmin(abs.(freq(spec) - lower_bound))
                val, idx_bl = findmin(abs.(freq(spec) - (lower_bound - 250)))
                @test (amp2db(power(spec)[idx_lb]) - amp2db(power(spec)[idx_bl])) > 18

                val, idx_ub = findmin(abs.(freq(spec) - upper_bound))
                val, idx_bu = findmin(abs.(freq(spec) - (upper_bound + 250)))
                @test (amp2db(power(spec)[idx_ub]) - amp2db(power(spec)[idx_bu])) > 18

            end
        end
    end


end

@testset "Modifier Functions" begin


    @testset "Modulate Signals" begin

        @testset "Amplitude Modulation" begin

            for modulation_frequency = 1:1:10
                x = randn(Fs, 1)
                @test_nowarn amplitude_modulate(x, modulation_frequency, Fs)
            end

            for modulation_frequency = 1.3:1:10
                x = randn(Fs, 1)
                @test_warn "Not a complete modulation" amplitude_modulate(x, modulation_frequency, Fs)
            end

        end

        @testset "ITD Modulation" begin

            cn = correlated_noise(Fs * 1, 2, 0.99)
            bn = bandpass_noise(cn, 300, 700, Fs)
            mn = amplitude_modulate(bn, 40, Fs)
            im = ITD_modulate(mn, 8, 24, -24, Fs)


            cn = correlated_noise(Fs * 1, 2, 0.99)
            bn = bandpass_noise(cn, 300, 700, Fs)
            mn = amplitude_modulate(bn, 40, Fs)
            im = ITD_modulate(mn, 8, 48, -48, Fs)
            
        end

    end

    @testset "RMS" begin

        for desired_rms = 01:0.1:1
            bn = bandpass_noise(Fs * 30, 2, 300, 700, Fs)
            bn = set_rms(bn, desired_rms)
            @test rms(bn) ≈ desired_rms
        end
    end


end



# @testset "Example Usage" begin

#     @testset "Correlated modulated bandpass noise with set RMS" begin

#         for correlation = 0.2:0.2:0.8
#             for lower_bound = 300:200:800
#                 for upper_bound = 1300:200:1800
#                     for modulation_frequency = 20:10:40
#                         for itd_samples = [24, 48]
#                             for itd_rate = [2, 4]
#                                 for desired_rms = 0.1:0.1:1
#                                     cn = correlated_noise(Fs * 2, 2, correlation)
#                                     bn = bandpass_noise(cn, lower_bound, upper_bound, Fs)
#                                     mn = amplitude_modulate(bn, modulation_frequency, Fs)
#                                     im = ITD_modulate(mn, itd_rate, itd_samples, -itd_samples, Fs)
#                                     of = set_rms(im, desired_rms)
#                                 end
#                             end
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end