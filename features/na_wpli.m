function [result] = na_wpli(recording, frequency_band, window_size, number_surrogate, p_value ,is_verbose)
    %NA_WPLI NeuroAlgo implementation of wpli that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    % NOTE: We are also only doing fullband eeg
    result = Result('wpli', recording);
    
    windowed_data = recording.get_windowed_data(window_size);
    [number_window,~,~] = size(windowed_data);
    %% Calculation on the windowed segments
    result.data.wpli = zeros(number_window, recording.number_channels, recording.number_channels);
    for i = 1:number_window
       if(is_verbose)
          disp(strcat("wPLI at window: ",string(i)," of ", string(number_window))); 
       end
       segment_data = squeeze(windowed_data(i,:,:));
       segment_wpli = wpli(segment_data, number_surrogate, p_value); 
       result.data.wpli(i,:,:) = segment_wpli;
    end
    
    
    
end

