%% Loading a .set file
% This will allow to load a .set file into a format that is amenable to analysis
recording = load_set('test_data.set','C:/Users/biapt/Documents/GitHub/NeuroAlgo/example/test_data');
%{ 
    The recording class is structured as follow:
    recording.data = an (channels, timepoints) matrix corresponding to the EEG
    recording.length_recoding = length in timepoints of recording
    recording.sampling_rate = sampling frequency of the recording
    recording.number_channels = number of channels in the recording
    recording.channels_location = structure containing all the data of the channels (i.e. labels and location in 3d space)
    recording.creation_data = timestamp in UNIX format of when this class was created
%}

%% Running the analysis
%{
    Currently we have the following 7 features that are usable with the
    recording class: wpli, dpli, hub location, permutation entropy, phase
    amplitude coupling, spectral power ratio, topographic distribution.

    If you want to get access to the features that are used without the
    recording class take a look at the /source folder
%}

% 