using DSP
"""
    Filter(filter)

Apply filter to the signal

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
mutable struct Filter
    filter::Array{DSP.DF2TFilter, 1}  # Filter object
    enable::Bool
    num_filters::Int
end
function Filter(filters::Any)
    AuditoryStimuli.Filter(filters, true, length(filters))
end
function modify(sink::Filter, buf)
    if sink.enable
        for idx in 1:sink.num_filters
            buf.data[:, idx] = DSP.filt(sink.filter[idx], buf.data[:, idx])
        end
    end
    return buf
end


