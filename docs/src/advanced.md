# Advanced Usage

The introduction provides a simple example but for efficent use the following considerations may be required.


## Threading

Running the audio stream in its own thread so you can process user input or run other code in parallel.
This is easily accomplised using `@spawn`, see: [example](https://github.com/rob-luke/AuditoryStimuli.jl/blob/master/examples/test_streamer.jl).


## Enabling/Disabling pipeline components

Enable or disable processing rather than modifying the pipeline.
Each modifier has an enable flag so that it can be disabled,
when disabled the signal is simply passed through and not modified.
