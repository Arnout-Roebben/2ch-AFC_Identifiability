% Experiments testing the identifiability for acoustic feedback paths based
% on the forward path feedforward filter being of larger order than the
% autoregressive (AR) model used to model the speech.
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

%% Check that current folder corresponds to 2ch-AFC_Identifiability
[~,curr_dir] = fileparts(pwd);
if ~strcmp(curr_dir,"2ch-AFC_Identifiability")
    error('Current fulder must correspond to ''2ch-AFC_Identifiability''!')
end

%% Cleanup
clear; clc; close all;
addpath(genpath('.'));
stream = RandStream('mt19937ar','Seed',0);

%% Parameters
p = struct();

% General
p.fs = 16e3; % Sampling frequency

% Audio
p.T = 45; % Length of recording [s]
p.Ld = 10; % Ground-truth AR model order (Supported: 10 or 20)

% Forward path
p.g_add = -3; % Gain [dB] to be added to MSG

% Feedback path
p.Lf = 64; % Length of true feedback path [samples]
p.Lf_hat = p.Lf; % Length of estimated feedback path [samples]
p.AFC_flag = 0; % Feedback canceller not updated in closed-loop (0) - Feedback canceller updated (1)

% Forward path type
% IIR (G_IIR-AP(q)), FIR (G_FIR(q)), Delay1 (G_Delay1(q)) or Delay2 (G_Delay2(q))
p.forward_path_type = 'IIR'; 
p.Lg_num = 11; % Order of feedforward filter in forward path [samples]
p.alpha = 1; % delay in forward path [samples]

% Algorithm
p.La = p.Ld; % Estimated AR model order [samples]
p.Lb = p.La+p.Lf_hat-1; % Length of filter obtained by convolving the estimated AR model and the estimated feedback path [samples]
p.update = 1*p.fs; % Apply feedback canceller only after p.update samples (to avoid instability due to non-converged feedback path)

% Metrics
p.N = 512; % Discrete Fourier transform (DFT) size

%% Simulation
% Prepare simulation
[s,stream,p] = prepare_simulation(p,stream);

% Simulation
if p.forward_path_type == "IIR"
    p.Lg_den = p.Lg_num;
    p.g_den = flip(p.g_num(1:end-1));
end
p = simulate_2chAFC(s,p);

% Metrics
[mis_f,mis_b,mis_a,cond_R, asg_dB] = compute_metrics(p);   

%% Visualisation
figure; 

% Feedback path
subplot(2,1,1); hold on;
plot(p.f); plot(p.fhat);
xlabel('Coefficient')
ylabel('Amplitude [Arb. unit]')
legend('F(q)','Fhat(q)');

% AR model
subplot(2,1,2); hold on;
plot(p.d); plot(p.a);
xlabel('Coefficient')
ylabel('Amplitude [Arb. unit]')
legend('D(q)','A(q)');