"""
    AmplitudeModulation(rate, phase, depth)

Apply amplitude modulation to the signal

Inputs
------
* `rate` (Hz) desired modulation rate to be applied to signal.
* `phase` phase of modulation to be applied to signal applied to signal.  
  Defaults to pi so that modulation starts at a minimum.
* `depth` modulation depth.

Output
------
* SampleBuf 

Example
-------
```julia
am = AmplitudeModulation(1, 0.0, 0.05)
attenuated_sound = write(am, original_sound)
```
"""
mutable struct AmplitudeModulation
    rate::Number 
    phase::Number
    depth::Number
    enable::Bool
    time::Float64
end

# TODO: Must be cleaner way to set defaults
AmplitudeModulation(a, b, c) = AmplitudeModulation(a, b, c, true, 0)
AmplitudeModulation(a, b) = AmplitudeModulation(a, b, 1, true, 0)
AmplitudeModulation(a) = AmplitudeModulation(a, π, 1, true, 0)

# TODO: Must be a nicer way to handle units than this
AmplitudeModulation(a::typeof(1.0u"Hz"), b, c) = AmplitudeModulation(a |> u"Hz" |> ustrip, b, c)
AmplitudeModulation(a::typeof(1u"Hz"), b, c) = AmplitudeModulation(a |> u"Hz" |> ustrip, b, c)
AmplitudeModulation(a::typeof(1.0u"Hz"), b) = AmplitudeModulation(a |> u"Hz" |> ustrip, b)
AmplitudeModulation(a::typeof(1u"Hz"), b) = AmplitudeModulation(a |> u"Hz" |> ustrip, b)
AmplitudeModulation(a::typeof(1.0u"Hz")) = AmplitudeModulation(a |> u"Hz" |> ustrip)
AmplitudeModulation(a::typeof(1u"Hz")) = AmplitudeModulation(a |> u"Hz" |> ustrip)

# TODO: Must be a smarter way to provide keyword functionality
function AmplitudeModulation(;rate::Number=1,
                             phase::Number=π,
                             depth::Number=1)
    AmplitudeModulation(Float64(rate), Float64(phase), Float64(depth), true, 0)
end

function modify(sink::AmplitudeModulation, buf)
    start_time = sink.time
    end_time = start_time + (size(buf, 1) / samplerate(buf))
    if sink.enable
        t = range(start_time, stop=end_time, length=size(buf, 1))
        M = 1 .* cos.(2 * π * sink.rate * t .+ sink.phase) .* sink.depth
        buf.data = (1 .+ M) .* buf.data
    end
    sink.time = end_time
    return buf
end


