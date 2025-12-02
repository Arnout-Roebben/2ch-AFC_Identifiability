function [mis_f,mis_b,mis_a,cond_R, asg_dB] = compute_metrics(p)
% Computes misalignment, condition number and added stable gain (ASG)
% metrics.
% 
% INPUT:
% p                     Struct      Struct with the following parameters:
% - N                   1X1         Discrete Fourier Transform (DFT) size
% - f                   p.LfX1      Feedback path coefficients.
% - fhat                P.LfhatX1   Estimated feedback path coefficients.
% - d                   p.LdX1      Ground truth AR model coefficients.
% - a                   p.LaX1      Estimated AR model coefficients.
% - forward_path_type   String      Forward path type to use.  
%                                   IIR (G_IIR-AP(q)), FIR (G_FIR(q)), Delay1 (G_Delay1(q)) or Delay2 (G_Delay2(q))
% - g_num               P.Lg_numX1  Forward path feedforward filter coefficients.
% 
% OUTPUT:
% mis_f                 1X1         Misalignment [dB] of the feedback path compared to the estimated one.
% mis_a                 1X1         Misalignment [dB] of the AR model compared to the estimated one.
% mis_b                 1X1         Misalignment [dB] of the convolution of the feedback path and AR 
%                                   model compared to the estimated one.
% cond_R                1X1         Condition number of inversion of the
%                                   correlation matrix R as used in the 2ch-AFC algorithm.
% asg_dB                1X1         ASG of the system with the estimated
%                                   feedback path as feedback canceller inserted.
%
% v1.0
% LICENSE: This software is distributed under the terms of the GNU GPLv3 License (See LICENSE.md).
% AUTHOR:  Arnout Roebben
% CONTACT: arnout.roebben@esat.kuleuven.be
% CITE: A. Roebben, T. van Waterschoot, J. Wouters and M. Moonen, 
% "Identifiability Conditions for Acoustic Feedback Cancellation with the 
% Two-Channel Adaptive Feedback Canceller Algorithm," Accepted for publication 
% in IEEE Open Journal of Signal Processing (OJSP), 2025.
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

% Misalignment
mis_f = 10*log10(sum(abs(fft(p.f,p.N) - fft(p.fhat,p.N)).^2)/sum(abs(fft(p.f,p.N)).^2)); % Misalignment [dB]
mis_b = 10*log10(sum(abs(fft(-conv(p.d,p.f),p.N) - fft(p.b,p.N)).^2)/sum(abs(fft(-conv(p.a,p.f),p.N)).^2)); % Misalignment [dB]
mis_a = 10*log10(sum(abs(fft(p.d,p.N) - fft(p.a,p.N)).^2)/sum(abs(fft(p.d,p.N)).^2)); % Misalignment [dB]

% Cond
cond_R = cond(p.R);

% ASG
if p.forward_path_type == "IIR"
    msg_dB_AFC = msg_calculation_iir(conv(p.f-p.fhat,[0;p.g_num]),flip(p.g_num),p.N);
else
    msg_dB_AFC = msg_calculation_iir(conv(p.f-p.fhat,[0;p.g_num]),1,p.N);
end
asg_dB = msg_dB_AFC - p.msg_dB;

end