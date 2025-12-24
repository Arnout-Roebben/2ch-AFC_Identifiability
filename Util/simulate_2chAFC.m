function p = simulate_2chAFC(s,p)
% A closed-loop simulation with two-channel adaptive feedback canceller
% (2ch-AFC) identification.
% 
% INPUT:
% p                     Struct       Struct with the following parameters:
% s                     (p.T*p.fs)X1 Desired speech input according to the
%                                    AR model in  p.d
% - La                  1X1          Order of estimated AR model.
% - Lg_num              1X1          Order of forward path feedforward filter.
% - Lg_den              1X1          Order of forward path feedback filter.
% - Lf                  1X1          Order of the feedback path.
% - Lf_hat              1X1          Order of the estimated feedback path.
% - Lb                  1X1          Lfhat + La - 1
% - forward_path_type   String       Forward path type to use.
%                                    IIR (G_IIR-AP(q)), FIR (G_FIR(q)), Delay1 (G_Delay1(q)) or Delay2 (G_Delay2(q))
% - g_num               p.Lg_numX1   Forward path feedforward filter coefficients.
% - g_den               p.Lg_denX1   Forward path feedforward filter coefficients.
% - g                   1X1          Linear gain corresponding to the gain in dB as p.msg_dB + p.g_add.
% - f                   p.LfX1       Feedback path coefficients
% - T                   1X1          Time [s] of desired speech input.
% - fs                  1X1          Sampling frequency [Hz].
% - AFC_flag            1X1          Feedback canceller not updated in closed-loop (0) - Feedback canceller updated (1)
%  -update              1X1          Time [s] before feedback canceller is
%                                    inserted in closed-loop, only used when AFC_flag=1.
% 
% OUTPUT:
% p                     Struct       Struct with same parameters as in
%                                    INPUT, supplemented with the following
%                                    parameters:
% - fhat                p.LFhatX1    Estimated feedback path coefficients. 
% - b                   p.LbX1       Convolution of estimated feedback path
%                                    coefficients and estimated AR model coefficients.
% - a                   p.LaX1       Estimated AR model.
% - R                   p.Lb+p.La-1  Correlation matrix as used in the 2ch-AFC algorithm.
%                       Xp.Lb+p.La-1 
% 
% v1.0
% LICENSE: This software is distributed under the terms of the MIT License (See LICENSE.md).
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

%% Initialisation
l_f_buffer = zeros(p.Lf,1); % Buffer of loudspeaker signal for F(q)
l_b_buffer = zeros(p.Lb,1); % Buffer of loudspeaker signal for B(q)
m_g_buffer = zeros(p.Lg_num-1,1); % Buffer of loudspeaker signal for Gn(q)
if p.forward_path_type == "IIR"
    l_g_buffer = zeros(p.Lg_den-2,1); % Buffer of loudspeaker signal for Gd(q)
end
m_buffer = zeros(p.La-1,1); % Buffer of mic signal
mf_prev = 0; % Initial previous value of feedback cancelled mic signal
fhat = zeros(p.Lf_hat,1); % Feedback canceller
b = zeros(p.Lb,1); % B(q)
a = [1;zeros(p.La-1,1)]; % A(q)
R_inv = pinv(eps*eye(p.La-1+p.Lb)); % Initial inverse correlation matrix
R = eps*eye(p.La-1+p.Lb); % Initial correlation matrix (only used when feedback canceller continuously updated)
r = zeros(p.La-1+p.Lb,1); % Initial cross-correlation vector (only used when feedback canceller continuously updated)

%% Simulation
for t = 1:p.T*p.fs % Loop over input

    % Forward path processing
    m_g_buffer = [mf_prev; m_g_buffer(1:end-1)];
    if  p.forward_path_type == "IIR"
        l = p.g*p.g_num'*m_g_buffer - p.g_den'*l_g_buffer;
    else
        l = p.g*p.g_num'*m_g_buffer;
    end

    % Clip loudspeaker signal
    if abs(l) > 1
        l = sign(l);
    end

    % Construct feedback signal
    if p.forward_path_type == "IIR"
        l_g_buffer = [l;l_g_buffer(1:end-1)];
    end
    l_f_buffer = [l;l_f_buffer(1:end-1)];
    e = p.f.'*l_f_buffer;

    % Microphone signal
    m = e + s(t);

    % Apply feedback canceller
    if p.AFC_flag && t >= p.update
        mf = m - fhat.'*l_f_buffer;
    else
        mf = m;
    end
    mf_prev = mf;

    % Identification
    l_b_buffer = [l; l_b_buffer(1:end-1)];
    in = [m_buffer;l_b_buffer]; % Input vector
    if p.AFC_flag && t >= p.Lb % Only when t>= p.Lb as otherwise update would happen with in=0 which results in unstable fhat
        k = R_inv*in; % Kalman gain
        R_inv = R_inv - (1/(1+1/in'*R_inv*in))*(k*k'); % Update correlation matrix
        r = r + (in*m);
        sol = (R_inv)*(r);
        a(2:end) = -sol(1:p.La-1);
        b = -sol(p.La:end);
        if ~any(isnan(filter(1,a,b))) && all(abs(filter(1,a,b)) < 1e2) % Update only if fhat does not explode
            fhat = filter(1,a,b); fhat = -fhat(1:p.Lf_hat);
            fhat = fhat - mean(fhat);
        end
        R = R + (in*in');
    elseif t >= p.Lb
        R = R + (in*in');
        r = r + (in*m);
    end

    % Update buffer of mic signals
    m_buffer = [m;m_buffer(1:end-1)];
end

% Calculate fhat only at the end when continuous updates of
% feedback canceller
if ~p.AFC_flag
    sol = pinv(R)*r;
    a(2:end) = -sol(1:p.La-1);
    b = -sol(p.La:end);
    fhat = filter(1,a,b); fhat = -fhat(1:p.Lf_hat);
    fhat = fhat - mean(fhat);
end

% Store result
p.fhat = fhat;
p.b = b;
p.a = a;
p.R = R;

end