function [result] = na_spectral_power_ratio(recording, window_size, time_bandwidth_product,number_tapers,spectrum_window_size,step_size)
    %NA_SPECTRAL_POWER_RATIO NeuroAlgo implementation of spr that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    
    %% Configuration Setup
    configuration = get_configuration();
    theta = configuration.bandpass.theta;
    alpha = configuration.bandpass.alpha;
    beta = configuration.bandpass.beta;
    
    %% Setting Result
    result = Result('sprectral power ratio', recording);
    result.parameters.window_size = window_size;
    result.parameters.time_bandwidth_product = time_bandwidth_product;
    result.parameters.number_tapers = number_tapers;
    result.parameters.spectrum_window_size = spectrum_window_size;
    result.parameters.step_size = step_size;
    
    %% Variable Initialization
    sampling_rate = recording.sampling_rate;
    windowed_data = recording.create_window(recording.data, window_size);
    [number_window,~,~] = size(windowed_data);
    
    %% Calculation on the windowed segments
    result.data.ratio_beta_alpha = zeros(1, number_window);
    result.data.ratio_alpha_theta = zeros(1,number_window);
    for i = 1:number_window
       print(strcat("Spectral Power Ratios at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       
       avg_spectrum_alpha = spectral_power(segment_data,sampling_rate, alpha, time_bandwidth_product,number_tapers,spectrum_window_size,step_size); 
       avg_spectrum_beta = spectral_power(segment_data, sampling_rate, beta, time_bandwidth_product,number_tapers,spectrum_window_size,step_size);
       avg_spectrum_theta = spectral_power(segment_data, sampling_rate, theta, time_bandwidth_product,number_tapers,spectrum_window_size,step_size);
       
       result.data.ratio_beta_alpha(i) = avg_spectrum_beta./avg_spectrum_alpha;
       result.data.ratio_alpha_theta(i) = avg_spectrum_alpha./avg_spectrum_theta;
    end
    
end
