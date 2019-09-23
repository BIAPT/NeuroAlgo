function [result] = na_wpli(recording, frequency_band, window_size, number_surrogate, p_value ,is_verbose)
    %NA_WPLI NeuroAlgo implementation of wpli that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    % NOTE: We are also only doing fullband eeg
    result = Result('wpli', recording);
    print(strcat("Filtering Data from ",string(frequency_band(1)), "Hz to ", string(frequency_band(2)), "Hz."),is_verbose);
    filtered_data = recording.filter_data(recording.data, frequency_band);
    windowed_data = recording.create_window(filtered_data, window_size);
    [number_window,~,~] = size(windowed_data);
    %% Calculation on the windowed segments
    result.data.wpli = zeros(number_window, recording.number_channels, recording.number_channels);
    for i = 1:number_window
       print(strcat("wPLI at window: ",string(i)," of ", string(number_window)),is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       segment_wpli = wpli(segment_data, number_surrogate, p_value); 
       result.data.wpli(i,:,:) = segment_wpli;
    end
    
    %% Average wPLI
    result.data.avg_wpli = squeeze(mean(result.data.wpli,1));
    
    %% Region specific wPLI

    % General Mask for the filtering (pre-computed)
    is_left = [recording.channels_location.is_left];
    is_right = [recording.channels_location.is_right];
    is_midline = [recording.channels_location.is_midline];
    is_lateral = [recording.channels_location.is_lateral];
    
    % Specific Mask
    left_lateral_mask = (is_left == 1 & is_lateral == 1);
    left_midline_mask = (is_left == 1 & is_midline == 1);
    right_lateral_mask = (is_right == 1 & is_lateral == 1);
    right_midline_mask = (is_right == 1 & is_midline == 1);
    
    % Calculating wpli for each region
    result.data.left_lateral_wpli = result.data.wpli(:, left_lateral_mask, left_lateral_mask);
    result.data.left_midline_wpli = result.data.wpli(:, left_midline_mask, left_midline_mask);
    result.data.right_lateral_wpli = result.data.wpli(:, right_lateral_mask, right_lateral_mask);
    result.data.right_midline_wpli = result.data.wpli(:, right_midline_mask, right_midline_mask);
    
    % Calculating average per region for each window
    result.data.avg_left_lateral_wpli = mean(squeeze(mean(result.data.left_lateral_wpli,2)),2);
    result.data.avg_left_midline_wpli = mean(squeeze(mean(result.data.left_midline_wpli,2)),2);
    result.data.avg_right_lateral_wpli = mean(squeeze(mean(result.data.right_lateral_wpli,2)),2);
    result.data.avg_right_midline_wpli = mean(squeeze(mean(result.data.right_midline_wpli,2)),2);    
end

