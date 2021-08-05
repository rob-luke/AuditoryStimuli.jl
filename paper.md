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

The `AuditoryStimuli.jl` software package provides researchers with a framework to generate real-time audio signals.
The package is designed for use in auditory research programs, neurofeedback applications, and audio signal processing development.
The package is developed on top of the SampledSignals library [@sampled-signals] to provide auditory specific functionality and encourage best practices in real-time audio generation and presentation.
As such, modules are provided to generate auditory signals, modify these signals, and output the resultant waveforms.
The package can be used to generate offline audio signals,
but when used as a real-time audio system, it provides safe guards for common mistakes which can cause signal distortions.


# Statement of need

There has been great improvement in standardising the analysis and post processing of research data
in the scientific fields of auditory perception, auditory neuroscience, and brain computer interface research,
However, desipite being critical for producing reproducible experiments, standardised tools for the generation of auditory stimuli have not typically been developed with the same open-source rigour.
A large portion of stimulus signals for auditory research is generated with shared code fragments without version control or efficent means of reporting errors.
As such, this package provide a documented and version controlled open-source framework for generating auditory stimuli.

A number of software packages exist for controling the presentation of psychoacoustic experiments [@psychopy2; @pychoacoustics; @Schönwiesner2021].
Simillarly, many packages exist for the analysis of acoustic signals [@python-sofa; @mcfee2015librosa]


# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$


# Citations



# Acknowledgements

This software has already been used in
[@luke2021analysis].

# References
