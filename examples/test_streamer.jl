using PortAudio, Unitful, AuditoryStimuli, SampledSignals, Printf
using Pipe: @pipe


# ###########################
# ## Helper functions
# ###########################


function get_stream(soundcard::String="Analog (3+4) (RME Fireface UCX)")
    a = PortAudio.devices()
    idx = [occursin("Fireface", d.name) for d in a]
    if sum(idx) > 1
        # Multiple fireface devices found, using the user specified one
        name = soundcard
    else
        # Only one fireface card found, so using that
        name = a[findfirst(idx)].name
    end
    @printf("Using device: %s\n", name)
    try
        # Open the stream to the specified sound card
        stream = PortAudioStream(name, 0, 2)
    catch
        @printf("Unable to connect to %s, printing available devices\n", name)
        PortAudio.devices()
        stream = PortAudioStream(name, 0, 2)
    end
end

function get_user_value(T=String, msg=""; maxval=9, minval=1, debug=false)
    print("$msg ")
    if T == String
        return readline()
    else
        try
            a =  parse(T,readline())
            debug && println(a)
        catch
            println("Sorry, I could not interpret your answer. Please try again")
            a = get_user_value(T,msg)
        end
        if a > maxval
            println("Number must be less than 10")
            a = get_user_value(T,msg)
        elseif a < minval
            println("Number must be more than 0")
            a = get_user_value(T,msg)
        end
    end
    return a
end


# ###########################
# ## Main function
# ###########################

soundcard = get_stream()
noise_source = NoiseSource(Float64, 48000, 2, 0.2)
amplify = Amplification(0.1, 0.01, 0.005)


noise_stream = Threads.@spawn begin
    while amplify.current_amplification > 0.001
        @pipe read(noise_source, 0.01u"s") |> modify(amplify, _)  |> write(soundcard, _)
    end
end

while amplify.current_amplification > 0.001
    a = get_user_value(String, "Select amplification: 1(quiet) to 9(loud)")
    print(a)
    try
        global amplify.target_amplification = parse(Float64, a) / 10.0
    catch
        global amplify.target_amplification = 0
        while amplify.current_amplification > 0.001
            sleep(0.2)
        end
        println("Shuting down")
    end
end

close(soundcard)
