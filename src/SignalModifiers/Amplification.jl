"""
    Amplification(target, current, change_limit)

Apply amplification to the signal.

This modifier allows the user to specify a `target` linear amplification
value that will be applied to the signal.
The modifier will then change the amplification of the
signal until the desired amplification is achieved. The rate
at which the amplification can be changed per frame is parameterised by
the `change_limit` parameter.

To slowly ramp a signal to a desired value set the `target` amplification
to the desired value, and the `change_limit` to a small value.

To instantly change the signal set the `change_limit` to infinity and
modify the `target` value.

When initialising the modifier specify the desired starting point
using the `current` parameter.

You can access the exact amplification at any time by querying the
`current` parameter.

Inputs
------
* `target` desired linear amplification factor to be applied to signal.
* `current` linear amplification currently applied to signal.  
  Also used to specify the intial value for the process.
* `change_limit` maximum change that can occur per frame.
* `enable` enable the modifier, if false the signal will be passed through without modification.

Example
-------
```julia
amplify = Amplification(0.1, 0.0, 0.05)
attenuated_sound = modify(amplify, original_sound)
```
"""
@with_kw mutable struct Amplification
    target::Float64=0             # Desired scaling factor
    current::Float64=0            # Current scaling factor
    change_limit::Float64=Inf     # Maximum change in scaling per frame
    enable::Bool=true             # Enable or pass through the signal

    Amplification(a, b, c, d) = new(a, b, c, d)
    Amplification(a, b, c) = new(a, b, c, true)
    Amplification(a, b) = new(a, b, Inf, true)
    Amplification(a) = new(a, 0, Inf, true)
end

function modify(sink::Amplification, buf)
    if sink.enable
        # Determine if the currect scaling needs to be updated
        if sink.target != sink.current
            error = sink.target - sink.current
            error_sign = sign(error)
            abs_error = abs(error)
            sink.current = sink.current + (min(sink.change_limit, abs_error) * error_sign)
        end
        buf.data = buf.data .* sink.current
    end
    return buf
end

