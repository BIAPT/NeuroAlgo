classdef Recording
    %Recording Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
        sampling_rate;
        number_channels;
        channels_location;
    end
    
    methods
        function obj = Recording(data,sampling_rate, number_channels, channels_location)
            %Recording Construct an instance of this class
            %   Detailed explanation goes here
            obj.data = data;
            obj.sampling_rate = sampling_rate;
            obj.number_channels = number_channels;
            obj.channels_location = channels_location;
        end
        
    end
end

