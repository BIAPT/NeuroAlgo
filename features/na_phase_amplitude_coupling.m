function [result] = na_phase_amplitude_coupling(recording, window_size, low_frequency_bandwith, high_frequency_bandwith, number_bins)
    %NA_PHASE_AMPLITUDE_COUPLING NeuroAlgo implementation of spr that works with Recording
    % NOTE: right now we are only doing non-overlapping window (in sec)
    configuration = get_configuration();
    result = Result('phase amplitude coupling', recording);
    sampling_rate = recording.sampling_rate;
    channels_location = recording.channels_location;
    windowed_data = recording.create_window(recording.data, window_size);
    [number_window,~,~] = size(windowed_data);
    
    anterior_mask = ([channels_location.is_anterior] == 1);
    posterior_mask = ([channels_location.is_posterior] == 1);
    
    %% Calculation on the windowed segments
    result.data.modulogram_all = zeros(number_window, number_bins);
    result.data.ratio_peak_through_all = zeros(1, number_window);
    result.data.modulogram_anterior = zeros(number_window, number_bins);
    result.data.ratio_peak_through_anterior = zeros(1, number_window);
    result.data.modulogram_posterior = zeros(number_window, number_bins);
    result.data.ratio_peak_through_posterior = zeros(1,number_window);
    
    for i = 1:number_window
        print(strcat("Phase Amplitude Coupling at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
        segment_data = squeeze(windowed_data(i,:,:));
       
        % Whole head
        [modulogram_all, ratio_peak_through_all] = phase_amplitude_coupling(segment_data,sampling_rate, low_frequency_bandwith, high_frequency_bandwith, number_bins);
        result.data.modulogram_all(i,:) = modulogram_all;
        result.data.ratio_peak_through_all(i) = ratio_peak_through_all;
       
        % Only the anterior part
        [modulogram_anterior, ratio_peak_through_anterior] = phase_amplitude_coupling(segment_data(anterior_mask),sampling_rate, low_frequency_bandwith, high_frequency_bandwith, number_bins);
        result.data.modulogram_anterior(i,:) = modulogram_anterior;
        result.data.ratio_peak_through_anterior(i) = ratio_peak_through_anterior;
        
        % Only the posterior part
        [modulogram_posterior, ratio_peak_through_posterior] = phase_amplitude_coupling(segment_data(posterior_mask),sampling_rate, low_frequency_bandwith, high_frequency_bandwith, number_bins);
        result.data.modulogram_posterior(i,:) = modulogram_posterior;
        result.data.ratio_peak_through_posterior(i) = ratio_peak_through_posterior;
    end
    
end