classdef Result
    %RESULT Hold the output data along with meta data of the
    %recording
    
    properties
        % result information
        type; % type of result data structure we have (e.g. wpli)
        data;
        metadata;
    end
    
    methods
        function obj = Result(type, recording)
            %RESULT Construct an instance of this class
            %   Detailed explanation goes here
            obj.type = type;
            obj.metadata = struct();
            obj.data = struct();
            
            obj.metadata.sampling_rate = recording.sampling_rate;
            obj.metadata.number_channels = recording.number_channels;
            obj.metadata.channels_location = recording.channels_location;
            obj.metadata.recording_creation_date = recording.creation_date;
        end
    end
end

