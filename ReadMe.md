# Identifiability Conditions for Acoustic Feedback Cancellation with the Two-Channel Adaptive Feedback Canceller Algorithm
# License
This work is licensed under the [GNU GPLv3 license](LICENSE.md). By downloading and/or installing this software and associated files on your computing system you agree to use the software under the terms and conditions as specified in the license agreement.

If this code has been useful for you, please cite [[1]](#References).

# About
In this repository [[2]](#References), the identifiability conditions of feedback paths within closed-loop acoustic systems are studied for one specific prediction error method (PEM) feedback cancellation algorithm, namely the two-channel adaptive feedback canceller (2ch-AFC) [[4]](#References). It is shown that identifiability is achieved when the order of the forward path feedforward filter exceeds the order of the autoregressive (AR) model that is assumed to generate the input. This condition, although only tailored to the 2ch-AFC algorithm, is a generalisation of the condition of [[4]](#References), where it is stated that identifiability is achieved when the delay in the forward path is equal to or exceeds the AR model order. Indeed, when the first AR model order filter coefficients are equal to zero, both conditions align with one another. 

This repository provides example code for the 2ch-AFC algorithm under the conditions as described in [[1]](#References). 

The manuscript of [[1]](#References) has also been released as a preprint [[3]](#References).

The code has been developed and tested in MATLAB R2024a.


# File structure
* [Main.m](Main.m): Main file to run the code.
* [LICENSE](LICENSE.md): License file.
* [ReadMe.md](ReadMe.md): ReadMe file.
* [Audio](Audio): Folder containing the audio files.
    - [AR.mat](Audio/AR.mat): File containing the ground-truth AR coefficients.
    - [f.mat](Audio/f.mat): File containing the ground-truth feedback path. This feedback path is a modified version of the feedback paths available at [[4]](#References).
* [Util](Util): Auxiliary code.
    - [compute_metrics.m](Util/compute_metrics.m): Computes the metrics after applying the 2ch-AFC algorithm.
    - [msg_calculation_iir.m](Util/msg_calculation_iir.m): Computes the maximum stable gain (MSG).
    - [prepare_simulation.m](Util/prepare_simulation.m): Creates the variables necessary to initialise the closed-loop simulation and 2ch-AFC algorithm application. 
    - [simulate_2chAFC.m](Util/simulate_2chAFC.m): Closed-loop simulation with application of the 2ch-AFC algorithm.

# References
[1]
```
@article{roebben2025IdentifiabilityConditions,
	title = {Identifiability Conditions for Acoustic Feedback Cancellation with the Two-Channel Adaptive Feedback Canceller Algorithm},
	journal = {IEEE Open J. Signal Process. (OJSP)},
	author = {Roebben, A. and van Waterschoot, T. and Wouters, J. and Moonen, M.},
	year = {2025},
	note = {Accepted for publication},
}
```

[2]
```
@misc{roebbenGithub,
  author = {Roebben, A.},
  title = {Identifiability Conditions for Acoustic Feedback Cancellation with the Two-Channel Adaptive Feedback Canceller Algorithm},
  year = {2025},
  howpublished = {GitHub repository},
  url = {https://github.com/Arnout-Roebben/2ch-AFC_Identifiability},
}
```

[3]
```
@misc{roebben2025IdentifiabilityConditionsPreprint,
      title={Identifiability Conditions for Acoustic Feedback Cancellation with the Two-Channel Adaptive Feedback Canceller Algorithm}, 
      author={Roebben, A. and van Waterschoot, T. and Wouters, J. and Moonen, M.},
      year={2025},
      eprint={2512.01466},
      archivePrefix={arXiv},
      primaryClass={eess.AS},
      url={https://arxiv.org/abs/2512.01466}, 
}
```

[4]
```
@article{sprietAdaptive2005,
	title = {Adaptive Feedback Cancellation in Hearing Aids with Linear Prediction of the Desired Signal},
	volume = {53},
	issn = {1941-0476},
	number = {10},
	journal = {IEEE Trans. Signal Process.},
	author = {Spriet, A. and Proudler, I. and Moonen, M. and Wouters, J.},
	month = oct,
	year = {2005},
	pages = {3749--3763}
}
```