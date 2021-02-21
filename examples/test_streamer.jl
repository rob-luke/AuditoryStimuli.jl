#=

White noise generator with variable volume
==========================================

This program generates white noise and plays it through your speakers.
The volume of the white noise can be adjusted via a command prompt.

Details
-------

Noise is played. The user is asked to select an amplification from 1-9.
When the user selects an amplification it is applied to the noise.
The noise is ramped to the desired value.
Simulatenously the user is asked for a new amplification.
The amplification of the noise can be modified at any time, it does not have
to have ramped all the way to the previously selected value.
If the user selects a value other than 1-9 the noise is ramped off
=#

using PortAudio, Unitful, AuditoryStimuli, SampledSignals, Printf
using Pipe: @pipe


# ###########################
# ## Helper functions
# ###########################

"""
This function returns the port audio stream matching the requested card
"""
function get_soundcard_stream(soundcard::String="Fireface")
    a = PortAudio.devices()
    idx = [occursin(soundcard, d.name) for d in a]
    if sum(idx) > 1
        error("Multiple soundcards with requested name ($soundcard) were found: $a")
    end
    name = a[findfirst(idx)].name
    println("Using device: $name")
    stream = PortAudioStream(name, 0, 2)
end

"""
This function presents a prompt to the user and ensures
the response is valid. If the response is valid it is returned.
If not, it returns `quit`.
"""
function query_prompt(query, typ)
    print(query, ": ")
    choice = uppercase(strip(readline(stdin)))
    if ((ret = tryparse(typ, choice)) != nothing) && (0 < ret < 10)
        return ret
    else
        println("A number between 1-9 was not entered... quiting")
        return "quit"
    end
end


# ###########################
# ## Main function
# ###########################

# Set up the audio pathway objects
soundcard = get_soundcard_stream()
noise_source = NoiseSource(Float64, 48000, 2, 0.2)
amplify = Amplification(0.1, 0.01, 0.005)

# Instansiate the audio stream in its own thread
noise_stream = Threads.@spawn begin
    while amplify.current_amplification > 0.001
        @pipe read(noise_source, 0.01u"s") |> modify(amplify, _) |> write(soundcard, _)
    end
end


# Main function
while amplify.current_amplification > 0.001
    a = query_prompt("Select amplification. 1(quiet) to 9(loud), or q(quit)",  Float64)

    if a isa Number
        # Update the target amplifcation
        setproperty!(amplify, :target_amplification, a / 10.0)
    else
        # Ramp the amplifcation to zero and then exit
        setproperty!(amplify, :target_amplification, 0.0)
        while amplify.current_amplification > 0.001; sleep(0.2); end
        println("Shuting down")
    end
end

close(soundcard)
