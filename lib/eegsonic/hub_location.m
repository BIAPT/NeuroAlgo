function [hd_channel_index, hd_channel_degree, hd_normalized_value, hd_graph] = hub_location(eeg_data, channels_location, number_surrogates, p_value, threshold)
%HUB_LOCATION choose from the the channels the channel with the highest
%degree
%   Input:
%       eeg_data: data to calculate the measures on
%       channels_location: information about the location of the channels
%       number_surrogate: number of surrogate analysis we want to do for
%       the creation of the wpli matrix
%       p_value: value of the p we want for the significance testing of the
%       wpli matrix
%   Output:
%       hd_channel_index: index of the channel with the highest degree
%       hd_channel_degree: the degree of the highest degree node
%       hd_normalized_value: the normalized value (anterior to posterior)
%       of the highest degree node 1 = the frontest electrode, 0 =
%       occipitalest electrode

    %% Calculate the wPLI for the full eeg
    full_wpli = wpli(eeg_data,number_surrogates, p_value);

    %% Threshold the wPLI depending on the top connection threshold
    % Find the threshold value
    sorted_wpli = sort(full_wpli(:));
    treshold_index = floor((1-threshold)*length(sorted_wpli));
    treshold_value = sorted_wpli(treshold_index);
    % Here we binarized the wpli by thresholding at the value

    full_wpli(full_wpli < treshold_value) = 0;
    hd_graph = full_wpli; % Here we save the thresholded high_degree graph
    full_wpli(full_wpli >= treshold_value) = 1;
     
    %% Caculate the unweighted degree of the network
    channels_degree = degrees_und(full_wpli);

    %% Find the channel with the highest degree
    [hd_channel_degree, hd_channel_index] = max(channels_degree);
    hd_normalized_value = threshold_anterior_posterior(hd_channel_index,channels_location);
end

