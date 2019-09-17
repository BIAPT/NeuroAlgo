function [ratio_beta_alpha,ratio_alpha_theta] = spectral_power_ratio(eeg_data,parameters)
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
    
    %% Pre processig (only for non-replay)
    eeg_data = reref(bpfilter(0.1,50,1000,eeg_data')');
    
    eeg_data = eeg_data';
    %% Create params struct for Chronux function
    params.tapers = [parameters.time_bandwith_product parameters.number_tapers];
    params.Fs = 1000; %eeg_info.sampling_rate;
    params.trialave = 1;
    window_parameters = [parameters.window_size parameters.step_size];    

    %% Theta
    params.fpass = [parameters.theta.bandwith];
    [spectrum_theta, ~, ~] = mtspecgramc(eeg_data, window_parameters, params);
    overall_spectrum_theta = mean(spectrum_theta,2);
    avg_spectrum_theta = mean(overall_spectrum_theta);
    
    %% Beta
    params.fpass = [parameters.beta.bandwith];
    [spectrum_beta, ~, ~] = mtspecgramc(eeg_data, window_parameters,params);
    overall_spectrum_beta = mean(spectrum_beta,2);
    avg_spectrum_beta = mean(overall_spectrum_beta);
    
    %% Alpha
    params.fpass = [parameters.alpha.bandwith];
    [spectrum_alpha, ~, ~] = mtspecgramc(eeg_data, window_parameters,params);
    overall_spectrum_alpha = mean(spectrum_alpha,2);
    avg_spectrum_alpha = mean(overall_spectrum_alpha);
    
    %% Ratio
    ratio_beta_alpha = avg_spectrum_beta./avg_spectrum_alpha;
    ratio_alpha_theta = avg_spectrum_alpha./avg_spectrum_theta;
    
end

