function [Recording] = load_set(file_name,path)
%LOAD_EEG will load the EEG data
%   file_name: name of the file to load
%   path: path to that file
%
%   Recording: structure containing the eeg data

    Recording = struct();

    % Currently supported format: .set files
    data = pop_loadset(file_name,path);
    Recording.eeg = data.data;
    Recording.sampling_rate = data.srate;
    Recording.number_channels = data.nbchan;
    Recording.channels_location = data.chanlocs;
    Recording.channels_info = data.chaninfo;
end

