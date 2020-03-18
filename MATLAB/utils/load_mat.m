function [recording] = load_mat(file_name)
%LOAD_MAT will load the EEG data from an exported mat file
%   file_name: name of the file to load
%   path: path to that file
%
%   recording: instance of a Recording containing the eeg data
    
    % Currently supported format: .set files
    data = load(file_name);
    data = data.EEG;
    
    recording = Recording(data.data, data.srate, data.nbchan, data.chanlocs);
end

