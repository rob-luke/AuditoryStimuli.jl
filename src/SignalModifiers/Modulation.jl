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
@with_kw mutable struct AmplitudeModulation
    rate::typeof(1.0u"Hz")=0.0u"Hz"
    phase::Number=π
    depth::Number=1
    enable::Bool=true
    time::Float64=0.0

    AmplitudeModulation(a::AbstractQuantity, b, c, d, e) = new(a, b, c, d, e)
    AmplitudeModulation(a::AbstractQuantity, b, c, d) = new(a, b, c, d, 0.0)
    AmplitudeModulation(a::AbstractQuantity, b, c) = new(a, b, c, true, 0.0)
    AmplitudeModulation(a::AbstractQuantity, b) = new(a, b, 1, true, 0.0)
    AmplitudeModulation(a::AbstractQuantity) = new(a, π, 1, true, 0.0)

end

function AmplitudeModulation(a::Number, args...)
    @error "You must use units for modulation rate."
end


function modify(sink::AmplitudeModulation, buf)
    start_time = sink.time
    end_time = start_time + (size(buf, 1) / samplerate(buf))
    if sink.enable
        t = range(start_time, stop=end_time, length=size(buf, 1))
        M = 1 .* cos.(2 * π * ustrip(sink.rate) * t .+ sink.phase) .* sink.depth
        buf.data = (1 .+ M) .* buf.data
    end
    sink.time = end_time
    return buf
end


