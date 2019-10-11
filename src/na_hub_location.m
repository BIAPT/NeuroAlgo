function [result] = na_hub_location(recording, frequency_band, window_size, number_surrogate, p_value ,threshold)
%NA_HUB_LOCATION Summary of this function goes here
%   Detailed explanation goes here
    configuration = get_configuration();
    result = Result('hub location', recording);
    print(strcat("Filtering Data from ",string(frequency_band(1)), "Hz to ", string(frequency_band(2)), "Hz."),configuration.is_verbose);
    filtered_data = recording.filter_data(recording.data, frequency_band);
    windowed_data = recording.create_window(filtered_data, window_size);
    [number_window,~,~] = size(windowed_data);
    %% Calculation on the windowed segments
    result.data.hub_index = zeros(1,number_window);
    result.data.hub_degree = zeros(1,number_window);
    result.data.hub_relative_position = zeros(1,number_window);
    result.data.graph = zeros(number_window, recording.number_channels, recording.number_channels);
    for i = 1:number_window
       print(strcat("Hub Location at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       segment_data = squeeze(windowed_data(i,:,:));
       % Calculating hub data for the segment
       [channel_index, channel_degree, relative_position, graph] = hub_location(segment_data, recording.channels_location, number_surrogate, p_value, threshold); 
       
       % Saving the hub data for this segment
       result.data.hub_index(i) = channel_index;
       result.data.hub_degree(i) = channel_degree;
       result.data.hub_relative_position(i) = relative_position;
       result.data.graph(i,:,:) = graph;
    end
end

