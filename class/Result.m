classdef Result
    %RESULT Hold the output data along with meta data of the
    %recording
    
    properties
        % result information
        type; % type of result data structure we have (e.g. wpli)
        data; % this is a struct containing arbitrary information
        
        % recording information
        sampling_rate;
        number_channels;
        channels_location;
        recording_creation_date;
        
    end
    
    methods
        function obj = Result(type, recording)
            %RESULT Construct an instance of this class
            %   Detailed explanation goes here
            obj.type = type;
            obj.data = struct();
            
            obj.sampling_rate = recording.sampling_rate;
            obj.number_channels = recording.number_channels;
            obj.channels_location = recording.channels_location;
            obj.recording_creation_date = recording.creation_date;
        end
    end
end

