"""
    Amplification(target_amplification, current_amplifcation, amplification_change_limit)

NoiseSource is a multi-channel noise signal generator. The noise on each channel is independent.

Inputs
------
* `target_amplification` the desired linear amplification factor to be applied to signal.
* `current_amplification` the linear amplification currently applied to signal.
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
    target_amplification::Float64     # Desired scaling factor
    current_amplification::Float64    # Current scaling factor
    amplification_change_limit::Float64    # Maximum change in scaling per frame
end
function Amplification(target_amplification::Number, current_amplification::Number, amplification_change_limit::Number)
    Amplification(target_amplification, current_amplification, amplification_change_limit)
end
function write(sink::Amplification, buf)
    # Determine if the currect scaling needs to be updated
    if sink.target_amplification != sink.current_amplification
        error = sink.target_amplification - sink.current_amplification
        error_sign = sign(error)
        abs_error = abs(error)
        sink.current_amplification = sink.current_amplification + (min(sink.amplification_change_limit, abs_error) * error_sign)
    end
    buf.data = buf.data .* sink.current_amplification
    return buf
end

