function [result] = na_spectral_power(recording, window_size, time_bandwidth_product,number_tapers,spectrum_window_size, bandpass, step_size)
    %NA_SPECTRAL_POWER NeuroAlgo implementation of spr that works with Recording
 
    configuration = get_configuration();
    
    %% Setting Result
    result = Result('sprectral power', recording);
    result.parameters.window_size = window_size;
    result.parameters.time_bandwidth_product = time_bandwidth_product;
    result.parameters.number_tapers = number_tapers;
    result.parameters.spectrum_window_size = spectrum_window_size;
    result.parameters.step_size = step_size;
    result.parameters.bandpass = bandpass;
    
    %% Variable Initialization
    sampling_rate = recording.sampling_rate;
    windowed_data = recording.create_window(recording.data, window_size);
    [number_window,~,~] = size(windowed_data);
    
    %% Calculation on the windowed segments
    result.data.avg_spectrums = zeros(1,number_window);
    result.data.spectrums = [];
    for i = 1:number_window
       print(strcat("Spectral Power at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       
       [avg_spectrum,spectrum,timestamp,frequency] = spectral_power(segment_data,sampling_rate, bandpass, time_bandwidth_product,number_tapers,spectrum_window_size,step_size); 
       
       result.data.avg_spectrums(i) = avg_spectrum; 
       if (i == 1)
          result.data.spectrums = spectrum; 
          result.data.timestamps = timestamp;
          result.data.frequencies = frequency;
       else
           result.data.spectrums = cat(3,result.data.spectrums,spectrum);
           result.data.timestamps = cat(2,result.data.timestamps,timestamp);
           result.data.frequencies = cat(2,result.data.frequencies, frequency);
       end
       %result.data.spectrums = [result.data.spectrums,spectrum]; % TODO: find a way to initialize this properly
    end
    
end
