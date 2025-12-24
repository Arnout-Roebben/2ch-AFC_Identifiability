function msg = msg_calculation_iir(filt_num,filt_den,N)
% Computes the maximum stable gain (MSG). 
% 
% INPUT:
% MSG           L_numX1     Feedforward coefficients of loop transfer function. 
% filt_den      L_denX1     Feedback coefficients of loop transfer function. 
% N             1X1         Discrete Fourier Transform (DFT) sie
% 
% OUTPUT:
% msg           1X1         Maximum stable gain (MSG) [dB].
% 
% v1.0
% LICENSE: This software is distributed under the terms of the GNU GPLv3 License (See LICENSE.md).
% AUTHOR:  Arnout Roebben
% CONTACT: arnout.roebben@esat.kuleuven.be
% CITE: A. Roebben, T. van Waterschoot, J. Wouters and M. Moonen, 
% "Identifiability Conditions for Acoustic Feedback Cancellation With the 
% Two-Channel Adaptive Feedback Canceller Algorithm," in 
% IEEE Open Journal of Signal Processing, vol. 7, pp. 1-10, 2025, 
% doi: 10.1109/OJSP.2025.3639934.
% and
% A. Roebben, “Github repository: Identifiability Conditions for Acoustic 
% Feedback Cancellation with the Two-Channel Adaptive Feedback Canceller Algorithm,” 
% https://github.com/Arnout-Roebben/2ch-AFC_Identifiability, 2025.
%
% A preprint is available at
% A. Roebben, T. van Waterschoot, J. Wouters, and M. Moonen, 
% "Identifiability Conditions for Acoustic Feedback Cancellation with the 
% Two-Channel Adaptive Feedback Canceller Algorithm," 2025, arxiv:2512.01466.
%
% This code is a modified version of the 'msg_calculation' function by T.
% van Waterschoot, as received through a GNU GPLv3 license. Modifications
% include an extension for IIR forward paths, renaming the variables, a modification
% of the number of input and output arguments, and 
% the removal of any code not required for the core functionality. 
%
% Copyright (C) 2025  Arnout Roebben
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

% Get frequency response of loop transfer function
[filt_freq,omega] = freqz(filt_num,filt_den,N);
filt_phase = unwrap(angle(filt_freq))/(2*pi);

% Find frequencies where phase equals n2pi
idx_intersect = find(diff(ceil(filt_phase)));
omega_low = omega(idx_intersect);
phase_low = filt_phase(idx_intersect);
omega_high = omega(idx_intersect+1);
phase_high = filt_phase(idx_intersect+1);
omega_diff = (omega_high-omega_low);
phase_diff = abs(phase_high-phase_low);
omega_interpolated = omega_high - phase_diff.*(omega_diff./phase_diff);

% Get frequency response of loop trasnfer function at frequencies where
% phase equals n2pi
filt_freq_interpolated = freqz(filt_num,filt_den,omega_interpolated);

% Get MSG [dB]
msg = -20*log10(max(abs(filt_freq_interpolated)));

end
