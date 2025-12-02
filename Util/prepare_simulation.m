function [s,stream,p] = prepare_simulation(p,stream)
% Prepares the simulation by creating the (desired speech) input, loading
% the feedback path, and determining the gain in the forward path.
% 
% INPPUT:
% p                     Struct       Struct containing the following parameters;
% - Ld                  1X1          Order of true autoregressive (AR) model.
% - La                  1X1          Order of estimated AR model.
% - Lg_num              1X1          Order of forward path feedforward filter.
% - Lf                  1X1          Order of the feedback path.
% - forward_path_type   String       Forward path type to use.
%                                    IIR (G_IIR-AP(q)), FIR (G_FIR(q)), Delay1 (G_Delay1(q)) or Delay2 (G_Delay2(q))
% - T                   1X1          Time [s] of desired speech input.
% - fs                  1X1          Sampling frequency [Hz].
% - g_add               1X1          Gain [dB] to be added to MSG
% stream                RandStream   Random stream to draw random numbers from.
% 
% OUTPUT:
% p                     Struct       Struct with same parameters as in
%                                    INPUT, supplemented with the following
%                                    parameters:
% - d                   p.LdX1       AR model coefficients.
% - f                   p.LfX1       Feedback path coefficients
% - msg_dB              1X1          Maximum stable gain (MSG) [dB]
% - g_num               p.Lg_numX1   Forward path feedforward filter coefficients.
% - g                   1X1          Linear gain corresponding to the gain in dB as p.msg_dB + p.g_add.
% s                     (p.T*p.fs)X1 Desired speech input according to the
%                                    AR model in  p.d
% stream                RandStream   See INPUT
%
% v1.0
% LICENSE: This software is distributed under the terms of the MIT License (See LICENSE.md).
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

% Select length of forward path processing
if p.forward_path_type == "Delay1"
    p.Lg_num = p.La+1;
end

% AR model of speech
d_AR = load('audio/AR.mat');
if p.Ld == 10
    p.d = d_AR.d10;
elseif p.Ld == 20
    p.d = d_AR.d20;
end
reset(stream); w = wgn(p.T*p.fs,1,1,1,stream); reset(stream); % Create white noise signal
s = filter(1,p.d,w); % Filter white noise using AR model
s = s/max(abs(s))*0.02; % Adjust amplitude

% Load feedback path
d_f = load('Audio/f.mat');
p.f = d_f.f;
p.f = p.f(1:p.Lf).';
p.f = p.f - mean(p.f);

% Forward path processing
if p.forward_path_type == "Delay1" 
    reset(stream);  p.g_num = randn(stream,[p.Lg_num-1 1]); reset(stream);  p.g_num(1:p.La-1) = 0; % Forward path processing
    p.g_num(end) = 1;
elseif p.forward_path_type == "Delay2"
    reset(stream);  p.g_num = randn(stream,[p.Lg_num-1 1]); reset(stream);  
    p.g_num(1:p.Lg_num-2) = 0;
    p.g_num(end) = 1;    
elseif p.forward_path_type == "FIR"
    reset(stream);  p.g_num = randn(stream,[p.Lg_num-1 1]); reset(stream);  
    p.g_num(1:p.alpha-1) = 0;
elseif p.forward_path_type == "IIR"
    reset(stream); stable_flag = 0;
    while stable_flag == 0
        p.g_num = randn(stream,[p.Lg_num-p.alpha-1 1]);
        if all(abs(roots(flip(p.g_num))) < 1)
            stable_flag = 1;
        end
    end
    reset(stream);
    p.g_num = [zeros(p.alpha,1);p.g_num]; % IIR
    p.g_num = p.g_num/p.g_num(end);        
end

% Forward path gain
if p.forward_path_type == "IIR"
    p.msg_dB = msg_calculation_iir(conv(p.f,[0;p.g_num]),flip(p.g_num),p.N);    
else
    p.msg_dB = msg_calculation_iir(conv(p.f,[0;p.g_num]),1,p.N);
end
gain_dB = p.msg_dB + p.g_add; % Adjust gain [dB]
p.g = 10^(gain_dB/20); % Gain
end