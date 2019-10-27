function [result] = na_topographic_distribution(recording, window_size, step_size)
    %NA_SPECTRAL_POWER_RATIO NeuroAlgo implementation of spr that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    
    %% Getting Configuration
    configuration = get_configuration();
    
    %% Setting Result
    result = Result('topographic distribution', recording);
    result.parameters.window_size = window_size;
    
    %% Variable Initialization
    sampling_rate = recording.sampling_rate;
    channels_location = recording.channels_location;
    windowed_data = recording.create_sliding_window(recording.data, window_size, step_size);
    [number_window,~,~] = size(windowed_data);
    
    anterior_mask = ([channels_location.is_anterior] == 1);
    posterior_mask = ([channels_location.is_posterior] == 1);
    %% Calculation on the windowed segments
    result.data.avg_power_ratio_front_posterior = zeros(1, number_window);
    result.data.power = zeros(number_window, recording.number_channels, (sampling_rate/2) + 1);
    for i = 1:number_window
       print(strcat("Topographic Distribution at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       power = topographic_distribution(segment_data, sampling_rate);
       
       
       result.data.power(i,:,:) = power;
       % TODO: FIX THIS ITS THE AVERAGE OF EVERYTHING IT DOESNT MAKE SENSE
       result.data.avg_power_ratio_front_posterior(i) = mean(power(anterior_mask),2) / mean(power(posterior_mask,2));
    end
    
end
