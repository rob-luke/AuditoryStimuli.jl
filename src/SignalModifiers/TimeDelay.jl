"""
    TimeDelay(channel, delay, enable, buffer)
    TimeDelay(channel, delay, enable, buffer; samplerate)

Delay the signal in specified channel.

Inputs
------
* `channel` which channel should have a time delay applied.
* `delay` delay to be applied in samples.  
* `enable` should the modifier be enabled.
* `buffer` initial values with which to pad the time delay. Defaults to zeros.
* `samplerate` keyword argument required if delay is specified in unit of time.


Example
-------
```julia
itd = TimeDelay(2, 12)
sound_with_itd = modify(itd, original_sound)
```
"""
Base.@kwdef mutable struct TimeDelay
    channel::Int=1
    delay::Int=0
    enable::Bool=true
    buffer::Array=[]

    function TimeDelay(c::Int, d::AbstractQuantity, args...; samplerate::Number)
        if isa(samplerate, AbstractQuantity)
            samplerate= samplerate |> u"Hz" |> ustrip
        end
        delay_seconds = d |> u"s" |> ustrip
        delay_samples = delay_seconds * samplerate
        if round(delay_samples) != delay_samples
            @info "Not rounded number of samples $delay_samples"
            delay_samples = round(delay_samples)
        end
        delay_samples = Int(delay_samples)
        TimeDelay(c, delay_samples, args...)
    end

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

