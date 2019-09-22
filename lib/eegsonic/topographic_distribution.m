function [ratio_front_back] = topographic_distribution(eeg_data,eeg_info,parameters,frontal_mask,posterior_mask)
%TOPOGRAPHIC_DISTRIBUTION Calculate the ratio of front to back power at a
%specific frequency
%   Input:
%       eeg_data: data to calculate the measures on
%       eeg_info: headset information
%       parameters: variables data as inputed by the user
%       frontal_mask: boolean mask for the midline electrodes
%       posterior_mask: boolean mask for the lateral electrode
%   Output:
%       ratio_front_back: ratio of the power between front and back
%       electrodes

    %% Channels Filtering

    % Relevant channels = frontal_channels and posterior_channels
    %% Spectral topographic map
    [eegspecdB,freqs,~,~,~] = spectopo(eeg_data,length(eeg_data),...,
                              eeg_info.sampling_rate,'chanlocs',...,
                              eeg_info.channels_location,'freqfac',1,...,
                              'freq',parameters.frequency,'plot','off');
    
    %% Frontal Averaging
    frontal_avg = mean(eegspecdB(frontal_mask==1),2);
    %% Posterior Averaging
    posterior_avg = mean(eegspecdB(posterior_mask==1),2); 
    %% Ratio Front and Posterior
    ratio_front_back = frontal_avg/posterior_avg;
end

