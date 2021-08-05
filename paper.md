---
title: 'AuditoryStimuli.jl: A Julia package for generating real-time auditory stimuli'
tags:
  - Julia
  - auditory
  - real-time
authors:
  - name: Robert Luke
    orcid: 0000-0002-4930-8351
    affiliation: "1"
affiliations:
 - name: Macquarie University, Macquarie University Hearing & Department of Linguistics, Australian Hearing Hub, Sydney, New South Wales, Australia
   index: 1
date: 19 July 2021
bibliography: paper.bib

---

# Summary

The `AuditoryStimuli.jl` software package provides researchers with a framework to generate real-time audio signals in the Julia programming language.
The package is designed for use in auditory research programs, neurofeedback applications, and audio signal processing development.
The package is developed on top of the SampledSignals library [@sampled-signals] to provide auditory specific functionality and encourage best practices in real-time audio generation.
As such, modules are provided to generate auditory signals, modify these signals, and output the resulting waveforms.
The package can be used to generate offline audio signals,
but when used as a real-time audio system, it provides safe guards for common mistakes which can cause signal distortions.


# Statement of need

There has been great improvement in standardising the analysis and post processing of research data
in the scientific fields of auditory perception, auditory neuroscience, and brain computer interface research [@gramfort2014mne; @oostenveld2011fieldtrip].
However, despite being critical for conducting reproducible experiments, standardised tools for the generation of auditory stimuli have typically not been developed with the same software engineering rigour.
A large portion of stimulus signals for auditory research are generated with privately shared code fragments,
without version control or efficient means of reporting errors.
As such, this package provides a documented and version-controlled open-source framework for generating auditory stimuli.

`AuditoryStimuli.jl` is specifically developed for real-time audio research applications.
A variety of software packages already exist for controlling the presentation of traditional block-design psychoacoustic experiments [@psychopy2; @pychoacoustics; @Schönwiesner2021, ],
and the post-processing the analysis of acoustic signals [@python-sofa; @mcfee2015librosa].
As such, this package does not focus on providing the scaffolding for traditional experimentation
such as block design experiments or alternative forced choice procedures;
users are directed to existing tools such as [@pychoacoustics] for this purpose.
Instead this package fills the need for a frame-based real-time signal processing framework.
`AuditoryStimuli.jl`  provides tools to generate real-time audio signals that can be dynamically adapted to the users responses or state.
I.e., the stimulus properties may change continuously and dynamically on a scale of milliseconds, rather than in pre-generated signals on the scale of seconds.

Real-time audio stimulus generation is also required for brain computer interface applications.
For example, methods have been developed to measure the brains response to sounds in real time [@DECHEVEIGNE2018206; @luke2016kalman].
This package provides a real-time framework which can be used to adapt the resulting audio according to an external signal, such as the brain state.

Real-time audio frameworks are required for developing audio signal processing algorithms.
For example, noise reduction, wind noise detection [@sapozhnykov2019wind], acoustic state detection [@robert2019blocked; @sapozhnykov2020headset],
and speech enhancement algorithms typically run using frame based processing, with frames of 2-4 ms.
`AuditoryStimuli.jl` provides the user with the ability to dynamically set processing parameters for each audio frame,
enabling real-time signal processing development.
Algorithm parameters can be varied and processing steps can be adaptively enabled.

Due to the real-time nature of the software package, fast mathematical computation is required.
Audio signal processing is usually deployed using assembly or C programming languages, as these provide excellent processing speed.
However, these low level languages require complex tooling and management of complex data structures,
which increases development time and decreases the rate at which researchers can iterate on signal-processing designs.
Instead `AuditoryStimuli.jl` is written in the Julia programming language [@bezanson2017julia],
which provides the convenience of a high level language while providing excellent computational speed.
The package is developed on top of the the SampledSignals library [@sampled-signals], which provides the sample- and frame-based infrastructure.
`AuditoryStimuli.jl` builds on top of this framework to provide auditory specific features.

`AuditoryStimuli.jl` provides functions to generate real-time audio signals and avoid abrupt changes in the stimulus that cause unwanted perceptual distortions.
When modifier functions are instantiated, the user can specify the maximum rate of change of the parameters.
Then during processing, the modifier functions will ensure that parameters can not change too quickly, which causes distortions such as clicks.
The package provides signal generators for common auditory stimuli such as noise, tones, and multi tone complexes.
Similarly, the package provides for both single channel and multi channel audio processing,
e.g.,  such as binaural stimuli with user specified interaural coherence.
Modifier functions are provided for modifying the amplitude, phase, frequency content, and amplitude modulation of the signals.
And tutorials are provided in the documentation which demonstrate how these generators and modifiers can be used together to produce common research stimuli.

Taken together, the `AuditoryStimuli.jl` package fills a need within the auditory research community for a open-source real-time audio framework.
The package addresses the communities need for a frame-based audio framework,
that is computationally efficient and can be used in neuro feedback applications as well as audio processing development.
An issue tracker and means for code contribution are provided.
And the package provides installation instructions, documentation, and tutorials.

# Notes

This software has already been used to generate stimuli for [@luke2021analysis].


# References
