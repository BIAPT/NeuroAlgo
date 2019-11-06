function [data_in] = sqi_sc(data_in)
% Usage: [data_in, array] = sqi_sc(data_in)

% input: data_in : structure containing, time, bvp, sc and skt signals from TPS sensor.
%                 
% Output: data_in : Same structure as data_in, with an added bvp_sc
%                       field. 
%
% Coded by: Pascal Fortin
% Supervised by: Stefanie Blain-Moraes, Jeremy R. Cooperstock
% McGill University, Montreal, Canada
% 

% Detailed description
% SC signal quality uses the following features
%   1. Minimum sc value from the sample to see if the finger was removed
%   (sudden approximately 0)
%   2. Max-min in sc value to detect abnormally wide range of values
%   3. Standard deviation in the values. 

%% 1 - Compute SQI
% Initialize an empty array to hold the sqi values
array = [];

%% 1.1 - Detrending filter
% Sampling frequency
Fs = 15;
% cut-off frequency
Fc_hp = 0.25;
% BVP Normalized cut-off frequency
nFc_hp = Fc_hp/Fs;
% 3rd order high-pass filter with nFc
[hfb, hfa] = butter(3,nFc_hp, 'high'); 

% For each segment in data_in
for n=1:length(data_in)
    
    % Set default sc_SQI to 1
    data_in{n}.sc_SQI = 1;

    % Compute Max-Min of skin conductance to make sure it does not vary
    % unreasonably
    temp_min = min(data_in{n}.sc);
    temp_maxmin = max(data_in{n}.sc)-min(data_in{n}.sc);
    
    % Detrent sc signal and compute std, reflecting undesired noise/fast
    % variations.
    temp_scsignal = filtfilt(hfb, hfa, data_in{n}.sc);
    temp_scstd = std(temp_scsignal);
       
    % Generate a first approximation of SC sqi
    % 100 chosen arbitrarily to visualize changes. Might have to be fine
    % tuned. 
    data_in{n}.sc_SQI = data_in{n}.sc_SQI*exp(-1.5*temp_scstd);
    
    % If during the measurement, the finger was removed
    if temp_min <= 0.1
        data_in{n}.sc_SQI = 0*data_in{n}.sc_SQI;
    end
    
    % If finger, abnormally large variations ?
    if max(diff(data_in{n}.sc)) > 1
        data_in{n}.sc_SQI = 0.4*data_in{n}.sc_SQI;
    end    
    
end

end