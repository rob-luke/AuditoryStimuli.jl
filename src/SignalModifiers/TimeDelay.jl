"""
    TimeDelay(channel, delay, trim_length, enable)

Delay the signal in specified channel.

Inputs
------
* `channel` which channel should have a time delay applied.
* `delay` delay to be applied in samples or unitful units.  
* `trim_length` should the length of the extended channels be trimmed so that the output data is the same length as the input data. By default this is true, so the last samples of your signal may be removed.

Output
------
* SampleBuf 

Example
-------
```julia
itd = TimeDelay(2, 12)
attenuated_sound = modify(itd, original_sound)
```
"""
Base.@kwdef mutable struct TimeDelay
    channel::Int=1
    delay::Int=0
    enable::Bool=true
    buffer::Array=[]

    function TimeDelay(c::Int, d::Int, e::Bool, b::Array)
        d >= 0 || error("Delay must be positive")
        length(b) == d || error("Length of buffer must match delay")
        return new(c, d, e, b)
    end
    function TimeDelay(c::Int, d::Int, e::Bool)
        d >= 0 || error("Delay must be positive")
        buffer = zeros(d, 1)
        return new(c, d, e, buffer)
    end
    function TimeDelay(c::Int, d::Int)
        d >= 0 || error("Delay must be positive")
        buffer = zeros(d, 1)
        return new(c, d, true, buffer)
    end
    function TimeDelay(c::Int)
        return new(c, 0, true, [])
    end
end

function modify(sink::TimeDelay, buf)

    if sink.enable && sink.delay != 0

            new_buffer = buf.data[end-sink.delay+1:end, sink.channel]
            new_data = [sink.buffer; buf.data[1:end - sink.delay, sink.channel]]
            buf.data[:, sink.channel] = new_data
            sink.buffer = new_buffer

    end
    return buf
end

