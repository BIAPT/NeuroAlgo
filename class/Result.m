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
            obj.metadata.length_recording = recording.length_recording;
            obj.metadata.number_channels = recording.number_channels;
            obj.metadata.channels_location = recording.channels_location;
            obj.metadata.recording_creation_date = recording.creation_date;
        end
        
        function is_saved = save(obj, filename, pathname)
            %% Need to create a struct with the right filename at the specified path
            disp(strcat("Saving the Result under name ", filename, " at ", pathname));
            result = struct();
            result.type = obj.type;
            result.metadata = obj.metadata;
            result.data = obj.data;
            
            full_path = strcat(pathname,filesep,filename,".mat");
            save(full_path,'result');
            
        end
    end
end

