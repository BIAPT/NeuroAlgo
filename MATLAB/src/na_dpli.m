function [result] = na_dpli(recording, frequency_band, window_size, step_size, number_surrogate, p_value)
    %NA_dPLI NeuroAlgo implementation of dpli that works with Recording
    
    %% Getting the Configuration
    configuration = get_configuration();
    
    %% Setting the Result
    result = Result('dpli', recording);
    % Saving the parameters used
    result.parameters.frequency_band = frequency_band;
    result.parameters.window_size = window_size;
    result.parameters.step_size = step_size;
    result.parameters.number_surrogate = number_surrogate;
    result.parameters.p_value = p_value;
    
    %% Filtering the data
    print(strcat("Filtering Data from ",string(frequency_band(1)), "Hz to ", string(frequency_band(2)), "Hz."),configuration.is_verbose);
    filtered_data = recording.filter_data(recording.data, frequency_band);
    %% Slice the recording into windows
    windowed_data = recording.create_sliding_window(filtered_data, window_size, step_size);
    [number_window,~,~] = size(windowed_data);
    
    %% Calculation on the windowed segments
    result.data.dpli = zeros(number_window, recording.number_channels, recording.number_channels);
    for i = 1:number_window
       print(strcat("dPLI at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       % Calculate the dpli
       segment_data = squeeze(windowed_data(i,:,:));
       segment_wpli = dpli(segment_data, number_surrogate, p_value); 
       % Storing the dpli
       result.data.dpli(i,:,:) = segment_wpli;
    end
    
    %% Average wPLI
    result.data.avg_dpli = squeeze(mean(result.data.dpli,1));
    
    %% Region specific wPLI

    % General Mask for the filtering (pre-computed)
    is_left = [recording.channels_location.is_left];
    is_right = [recording.channels_location.is_right];
    is_midline = [recording.channels_location.is_midline];
    is_lateral = [recording.channels_location.is_lateral];
    is_anterior = [recording.channels_location.is_anterior];
    is_posterior = [recording.channels_location.is_posterior];
    
    % Specific Mask
    is_left_lateral = (is_left & is_lateral);
    is_left_lateral_anterior = (is_left_lateral & is_anterior);
    is_left_lateral_posterior = (is_left_lateral & is_posterior);
    
    is_left_midline = (is_left & is_midline);
    is_left_midline_anterior = (is_left_midline & is_anterior);
    is_left_midline_posterior = (is_left_midline & is_posterior);
    
    is_right_lateral = (is_right & is_lateral);
    is_right_lateral_anterior = (is_right_lateral & is_anterior);
    is_right_lateral_posterior = (is_right_lateral & is_posterior);
    
    is_right_midline = (is_right & is_midline);
    is_right_midline_anterior = (is_right_midline & is_anterior);
    is_right_midline_posterior = (is_right_midline & is_posterior);
    
    

    % Calculating wpli for each region
    result.data.left_lateral_dpli = result.data.dpli(:, is_left_lateral, is_left_lateral);
    result.data.left_lateral_anterior_dpli = result.data.dpli(:, is_left_lateral_anterior, is_left_lateral_anterior);
    result.data.left_lateral_posterior_dpli = result.data.dpli(:, is_left_lateral_posterior, is_left_lateral_posterior);    
    
    result.data.left_midline_dpli = result.data.dpli(:, is_left_midline, is_left_midline);
    result.data.left_midline_anterior_dpli = result.data.dpli(:, is_left_midline_anterior, is_left_midline_anterior);
    result.data.left_midline_posterior_dpli = result.data.dpli(:, is_left_midline_posterior, is_left_midline_posterior); 
    
    result.data.right_lateral_dpli = result.data.dpli(:, is_right_lateral, is_right_lateral);
    result.data.right_lateral_anterior_dpli = result.data.dpli(:, is_right_lateral_anterior, is_right_lateral_anterior);
    result.data.right_lateral_posterior_dpli = result.data.dpli(:, is_right_lateral_posterior, is_right_lateral_posterior);
    
    result.data.right_midline_dpli = result.data.dpli(:, is_right_midline, is_right_midline);
    result.data.right_midline_anterior_dpli = result.data.dpli(:, is_right_midline_anterior, is_right_midline_anterior);
    result.data.right_midline_posterior_dpli = result.data.dpli(:, is_right_midline_posterior, is_right_midline_posterior);    
    
    % Calculating average per region for each window
    result.data.avg_left_lateral_dpli = average_connectivity(result.data.left_lateral_dpli);
    result.data.avg_left_lateral_anterior_dpli = average_connectivity(result.data.left_lateral_anterior_dpli);
    result.data.avg_left_lateral_posterior_dpli = average_connectivity(result.data.left_lateral_posterior_dpli);
    
    
    result.data.avg_left_midline_dpli = average_connectivity(result.data.left_midline_dpli);
    result.data.avg_left_midline_anterior_dpli = average_connectivity(result.data.left_midline_anterior_dpli);
    result.data.avg_left_midline_posterior_dpli = average_connectivity(result.data.left_midline_posterior_dpli);
    
    result.data.avg_right_lateral_dpli = average_connectivity(result.data.right_lateral_dpli);
    result.data.avg_right_lateral_anterior_dpli = average_connectivity(result.data.right_lateral_anterior_dpli);
    result.data.avg_right_lateral_posterior_dpli = average_connectivity(result.data.right_lateral_posterior_dpli);
    
    result.data.avg_right_midline_dpli = average_connectivity(result.data.right_midline_dpli);    
    result.data.avg_right_midline_anterior_dpli = average_connectivity(result.data.right_midline_anterior_dpli);    
    result.data.avg_right_midline_posterior_dpli = average_connectivity(result.data.right_midline_posterior_dpli);     
    
    % Calculating the ratio anterior / posterior for the four value
    result.data.avg_left_lateral_ratio = result.data.avg_left_lateral_anterior_dpli / result.data.avg_left_lateral_posterior_dpli;
    result.data.avg_left_midline_ratio = result.data.avg_left_midline_anterior_dpli / result.data.avg_left_midline_posterior_dpli;
    result.data.avg_right_lateral_ratio = result.data.avg_right_lateral_anterior_dpli / result.data.avg_right_lateral_posterior_dpli;
    result.data.avg_right_midline_ratio = result.data.avg_right_midline_anterior_dpli / result.data.avg_right_midline_posterior_dpli;
end