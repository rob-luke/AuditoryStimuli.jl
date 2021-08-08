using DSP
"""
    Filter(filters)

Apply filter to the signal

Inputs
------
* `filters` array of DSP filter objects.


Example
-------
```julia
using DSP
responsetype = Bandpass(500, 4000; fs=48000)
designmethod = Butterworth(4)
zpg = digitalfilter(responsetype, designmethod)
f_left = DSP.Filters.DF2TFilter(zpg)
f_right = DSP.Filters.DF2TFilter(zpg)

bandpass = AuditoryStimuli.Filter([f_left, f_right])
filtered_sound = modify(bandpass, original_sound)
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


