"""
    Amplification(target, current_amplifcation, change_limit)

Apply amplification to the signal

Inputs
------
* `target` the desired linear amplification factor to be applied to signal.
* `current` the linear amplification currently applied to signal.
  Also used to specify the intial value for the process.
* `amplification_step_change_limit` the maximum change in amplfication that can occur per frame.

Output
------
* SampleBuf 

Example
-------
```julia
amplify = Amplification(0.1, 0.0, 0.05)
attenuated_sound = write(amplify, original_sound)
```
"""
mutable struct Amplification
    target::Float64           # Desired scaling factor
    current::Float64          # Current scaling factor
    change_limit::Float64     # Maximum change in scaling per frame
end
function Amplification(;target::Number,
                        current::Number,
                        change_limit::Number)
    Amplification(Float64(target), Float64(current), Float64(change_limit))
end

function modify(sink::Amplification, buf)
    # Determine if the currect scaling needs to be updated
    if sink.target != sink.current
        error = sink.target - sink.current
        error_sign = sign(error)
        abs_error = abs(error)
        sink.current = sink.current + (min(sink.change_limit, abs_error) * error_sign)
    end
    buf.data = buf.data .* sink.current
    return buf
end

