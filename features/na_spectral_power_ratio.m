function [result] = na_spectral_power_ratio(recording, window_size, time_bandwith_product,number_tapers,spectrum_window_size,step_size, is_verbose)
    %NA_SPECTRAL_POWER_RATIO NeuroAlgo implementation of spr that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    
    result = Result('sprectral power ratio', recording);
    [theta, alpha, beta] = cfg_get_frequencies();
    sampling_rate = recording.sampling_rate;
    windowed_data = recording.create_window(recording.data, window_size);
    [number_window,~,~] = size(windowed_data);
    %% Calculation on the windowed segments
    result.data.ratio_beta_alpha = zeros(1, number_window);
    result.data.ratio_alpha_theta = zeros(1,number_window);
    for i = 1:number_window
       print(strcat("Spectral Power Ratios at window: ",string(i)," of ", string(number_window)),is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       
       avg_spectrum_alpha = spectral_power(segment_data,sampling_rate, alpha, time_bandwith_product,number_tapers,spectrum_window_size,step_size); 
       avg_spectrum_beta = spectral_power(segment_data, sampling_rate, beta, time_bandwith_product,number_tapers,spectrum_window_size,step_size);
       avg_spectrum_theta = spectral_power(segment_data, sampling_rate, theta, time_bandwith_product,number_tapers,spectrum_window_size,step_size);
       
       result.data.ratio_beta_alpha(i) = avg_spectrum_beta./avg_spectrum_alpha;
       result.data.ratio_alpha_theta(i) = avg_spectrum_alpha./avg_spectrum_theta;
    end
    
end

function [theta,alpha,beta] = cfg_get_frequencies()
    theta = [4 7];
    alpha = [7 13];
    beta = [12 38];
end
