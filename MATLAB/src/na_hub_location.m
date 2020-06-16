function [result] = na_hub_location(recording, frequency_band, window_size, step_size, number_surrogate, p_value ,threshold, a_degree, a_bc)
%NA_HUB_LOCATION will calculate hub locations
%(as defined by betweeness-centrality and degree) for the whole recording 
%of EEG data and store it inside a result data structure. 
%
%   this function will take a EEG data bundled inside an recording instance
%   and will calculate wPLI on segment of the data. It will then binarize
%   these matrices of connectivity before calculating the binary hub
%   location. It will output both the X-coordinate position of the hub
%   along the anterior-posterior axis and the weights calculated to defined
%   a hub. The hub here is defined as the maximum values in the map formed
%   by doing degree+ betweness_centrality.
%   
%   input:
%   recording: a EEG data bundled into a recording instance
%   frequency_band: the frequency band at which to filter the data
%   window_size: the window size onto which to cut the segment of data
%   step_size: the step size at which to jump from one window to another if
%   its the same as the window size it will be a jumpy windowing.
%   number_surrogate: the number of surrogate wPLI matrices to make the
%   null distribution for the corrected wPLI calculation
%   p_value: p value at which to say that a connection is significant
%   threshold: from 0 to 1 it's the amount of top connection we want to
%   keep in the wPLI->binary_wpli.
%   a_degree: weight to put on the degree for the definition of hub
%   a_bc: weight to put on the betweeness centrality for the definition of
%   hub
%
%   output:
%   result: a datastructure containing all the parameters information,
%   metadata as well as the output of the hub location.
%
%   example usage:
%   recording = load_set('name_of_data.set',path_to_data);
%   frequency_band = [7 13]; 
%   window_size = 10; 
%   number_surrogate = 10; 
%   p_value = 0.05; 
%   threshold = 0.10;
%   step_size = 10;
%   result_hl = na_hub_location(recording, frequency_band, window_size, step_size, number_surrogate, p_value, threshold);

    %% Getting the configuration
    configuration = get_configuration();
    
    %% Setting the Result
    result = Result('hub location', recording);
    result.parameters.frequency_band = frequency_band;
    result.parameters.window_size = window_size;
    result.parameters.number_surrogate = number_surrogate;
    result.parameters.p_value = p_value;
    result.parameters.threshold = threshold;
    result.parameters.step_size = step_size;
    result.parameters.a_degree = a_degree;
    result.parameters.a_bc = a_bc;
    
    %% Filtering the data
    print_message(strcat("Filtering Data from ",string(frequency_band(1)), "Hz to ", string(frequency_band(2)), "Hz."),configuration.is_verbose);
    [recording] = recording.filter_data(recording.data, frequency_band);
    
    % Here we init the sliding window slicing 
    recording = recording.init_sliding_window(window_size, step_size);
    number_window = recording.max_number_window;
    location = recording.channels_location;
    
    
    %% Calculation on the windowed segments
    result.data.wpli = zeros(number_window, recording.number_channels, recording.number_channels);
    result.data.hub_index = zeros(1,number_window);
    result.data.hub_weights = zeros(1,recording.number_channels);
    for i = 1:number_window
       print_message(strcat("Hub Location at window: ",string(i)," of ", string(number_window)),configuration.is_verbose); 
       [recording, segment_data] = recording.get_next_window();
       
       % Calculating the wPLI and binarize it
       segment_wpli = wpli(segment_data, number_surrogate, p_value); 
       result.data.wpli(i,:,:) = segment_wpli;
       b_wpli = binarize_matrix(threshold_matrix(segment_wpli, threshold));
       
       % Calculating hub data for the segment
       [hub_index, weights] = binary_hub_location(b_wpli, location, a_degree, a_bc);
       
       % Saving the hub data for this segment
       result.data.hub_index(i) = hub_index;
       result.data.hub_weights(i,:) = weights;
    end
end

