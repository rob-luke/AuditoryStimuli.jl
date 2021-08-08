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
Base.@kwdef mutable struct AmplitudeModulation
    rate::Number=0
    phase::Number=π
    depth::Number=1
    enable::Bool=true
    time::Float64=0.0

    AmplitudeModulation(a, b, c) = new(a, b, c, true, 0.0)
    AmplitudeModulation(a, b) = new(a, b, 1, true, 0.0)
    AmplitudeModulation(a) = new(a, π, 1, true, 0.0)
    AmplitudeModulation() = new(0, π, 1, true, 0.0)

    AmplitudeModulation(;rate::Number=1,
                         phase::Number=π,
                         depth::Number=1) = new(rate, phase, depth)

end

AmplitudeModulation(a::AbstractQuantity, args...) = AmplitudeModulation(a |> u"Hz" |> ustrip, args...)

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


