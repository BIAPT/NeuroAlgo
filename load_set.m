function [eeg,sampling_rate,number_channels,channels_location,channels_info] = load_set(file_name,path,type)
%LOAD_EEG will load the EEG data
%   file_name: name of the file to load
%   path: path to that file
%   type: type of the file to load (.set, edf)

    % Currently supported format: .set files
    if(strcmp(type,'set'))
        data = pop_loadset(file_name,path);
        eeg = data.data;
        sampling_rate = data.srate;
        number_channels = data.nbchan;
        channels_location = data.chanlocs;
        channels_info = data.chaninfo;
    end
end

