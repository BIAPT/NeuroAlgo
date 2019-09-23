function [avg_spectrum] = spectral_power(eeg_data,sampling_rate, frequency_band,time_bandwith_product,number_tapers,window_size,step_size)
%SPECTRAL_POWER_RATIO calculate the spectral power ratio between the beta
%and alpha band & between the alpha and theta band
%   Input:
%       eeg_data: data to calculate the measures on
%       eeg_info: headset information
%       parameters: variables data as inputed by the user
%   Output:
%       ratio_beta_alpha: ratio between the beta and alpha band
%       ratio_alpha_theta: ratio between the alpha and theta band

%NOTE: Gram mistake in the whole app (bandwith -> need to be bandwidth)
    
    %% Setup Variables
    eeg_data = eeg_data';
    %% Create params struct for Chronux function
    params.tapers = [time_bandwith_product number_tapers];
    params.Fs = sampling_rate;
    params.trialave = 1;
    window_parameters = [window_size step_size];    

    %% Spectral Power
    params.fpass = frequency_band;
    [spectrum, ~, ~] = mtspecgramc(eeg_data, window_parameters, params);
    overall_spectrum = mean(spectrum,2);
    avg_spectrum = mean(overall_spectrum);
    
end

