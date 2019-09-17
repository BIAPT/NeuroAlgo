function [EEG] = load_set(file_name,path)
%LOAD_EEG will load the EEG data
%   file_name: name of the file to load
%   path: path to that file

    EEG = struct();
    EEG.data = [];
    EEG.sampling_rate = -1;
    EEG.number_channels = -1;
    EEG.channels_location = [];
    EEG.channels_info = [];

    % Currently supported format: .set files
    if(strcmp(type,'set'))
        data = pop_loadset(file_name,path);
        EEG.data = data.data;
        EEG.sampling_rate = data.srate;
        EEG.number_channels = data.nbchan;
        EEG.channels_location = data.chanlocs;
        EEG.channels_info = data.chaninfo;
    end
end

