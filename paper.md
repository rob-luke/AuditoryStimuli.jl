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
The package is developed on top of the SampledSignals library [@sampled-signals] to provide auditory specific functionality and encourage best practices in real-time audio generation and presentation.
As such, modules are provided to generate auditory signals, modify these signals, and output the resultant waveforms.
The package can be used to generate offline audio signals,
but when used as a real-time audio system, it provides safe guards for common mistakes which can cause signal distortions.


# Statement of need

There has been great improvement in standardising the analysis and post processing of research data
in the scientific fields of auditory perception, auditory neuroscience, and brain computer interface research [@gramfort2014mne; @oostenveld2011fieldtrip].
However, desipite being critical for conducting reproducible experiments, standardised tools for the generation of auditory stimuli have typically not been developed with the same software engineering rigour.
A large portion of stimulus signals for auditory research is generated with shared code fragments without version control or efficent means of reporting errors.
As such, this package provide a documented and version controlled open-source framework for generating auditory stimuli.

`AuditoryStimuli.jl` is specifically developed for real-time audio applications and research.
A number of software packages already exist for controling the presentation of traditional block-design psychoacoustic experiments [@psychopy2; @pychoacoustics; @Schönwiesner2021],
and the post-processing the analysis of acoustic signals [@python-sofa; @mcfee2015librosa].
As such, this package does not focus on providing the scaffolding for traditional experimentation
such as block design experiments, alternative forced choice procedures, etc;
users are directed to existing tools such as [@pychoacoustics].
Instead this package provides tools to generate real-time audio signals that can be dynamically adapted to the users responses or state.
I.e., the stimulus properties may change continously and dynamically on a scale of milliseconds,
rather than in pre-generated signals on the scale of seconds.

A real-time audio frameworks are required for developing audio signal processing algorithms.
For example, noise reduction, wind noise detection [@sapozhnykov2019wind], or acoustic state detection [@robert2019blocked; @sapozhnykov2020headset]



Explain the need for fast computation. Julia [@bezanson2017julia]



Sudden changes cause distortions. Describe setting values






# Acknowledgements

This software has already been used in [@luke2021analysis].


# References
