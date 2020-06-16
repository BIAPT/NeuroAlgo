%% Loading a .set file
% This will allow to load a .set file into a format that is amenable to analysis
% The first argument is the name of the .set you want to load and the
% second argument is the path of the folder containing that .set file
% Here I'm getting it programmatically because my path and your path will
% be different.
[filepath,name,ext] = fileparts(mfilename('fullpath'));
test_data_path = strcat(filepath,'/test_data');
recording = load_set('test_data.set',test_data_path);

% wPLI
frequency_band = [7 13]; % This is in Hz
window_size = 20; % This is in seconds and will be how we chunk the whole dataset
number_surrogate = 20; % Number of surrogate wPLI to create
p_value = 0.05; % the p value to make our test on
step_size = 10;
a_degree = 1.0;
a_bc = 1.0;
result_wpli = na_wpli(recording, frequency_band, window_size, step_size, number_surrogate, p_value);

% Calculating Hub Location on the each window of wpli
channels_location = result_wpli.metadata.channels_location;

% calculate hub location
t_level_wpli = 0.2;
wpli = result_wpli.data.wpli;
[num_window, num_channels,~] = size(wpli);

% Here we are iterating on each window of the wpli matrices, binarize them
% and then running the binary_hub_location it
hub_map = zeros(num_window, num_channels);
median_location = zeros(1,num_window);
max_location = zeros(1,num_window);
for i = 1:num_window   
    % binarized the wpli matrix
    b_wpli = binarize_matrix(threshold_matrix(squeeze(wpli(i,:,:)), t_level_wpli));
    [hub_location, weights] = binary_hub_location(b_wpli, channels_location, a_degree, a_bc);
    hub_map(i,:) = weights;
end

% We are showing this stack of weights map into a small movie
filename = 'hub_location_technique_comparison';
make_video_hub_location(filename, hub_map, channels_location, step_size)
