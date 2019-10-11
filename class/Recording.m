classdef Recording
    %Recording Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
        length_recording;
        sampling_rate;
        number_channels;
        channels_location;
        creation_date;
    end
    
    methods
        function obj = Recording(data, sampling_rate, number_channels, channels_location)
            %Recording Construct an instance of this class
            %   Detailed explanation goes here
            obj.data = data;
            obj.sampling_rate = sampling_rate;
            obj.number_channels = number_channels;
            obj.channels_location = channels_location;
            obj.length_recording = length(data);
            obj.creation_date = posixtime(datetime());
            
            % Label whether the channels is anterior or posterior
            epsilon = 0.000001;
            for i = 1:obj.number_channels
                x = obj.channels_location(i).X;
                y = obj.channels_location(i).Y;
                % Anterior
                if(x > -epsilon)
                    obj.channels_location(i).is_anterior = 1;
                else
                    obj.channels_location(i).is_anterior = 0;
                end
                
                % Posterior
                if(x < epsilon)
                    obj.channels_location(i).is_posterior = 1;
                else
                    obj.channels_location(i).is_posterior = 0;
                end
                
                % Left
                if(y > -epsilon)
                    obj.channels_location(i).is_left = 1;
                    [is_midline, is_lateral] = obj.get_left_region(x,y);
                    obj.channels_location(i).is_midline = is_midline;
                    obj.channels_location(i).is_lateral = is_lateral;
                else
                    obj.channels_location(i).is_left = 0;
                end
                
                % Right
                if(y < epsilon)
                    obj.channels_location(i).is_right = 1;
                    [is_midline, is_lateral] = obj.get_right_region(x,y);
                    obj.channels_location(i).is_midline = is_midline;
                    obj.channels_location(i).is_lateral = is_lateral;
                else
                    obj.channels_location(i).is_right = 0;
                end
            end
        end
        
        %% Helper Function
        function [is_midline, is_lateral] = get_left_region(obj,x,y)
            % Variable Initialization
            is_midline = 0;
            is_lateral = 0;
            
            X = [6.02115996400000, 0.284948655000000, -4.49482169800000];
            Y = [4.45938718700000, 5.47913021000000, 5.83124149800000];
            [coefficients] = polyfit(X, Y, 1);
            slope = coefficients(1);
            intercept = coefficients(2);

            % Check if we are part of the three points
            for i=1:length(X)
               if(x == X(i))
                   is_midline = 1;
                   is_lateral = 1;
                   return;
               end
            end

            %Check if we are lateral and midline
            y_threshold = slope*x + intercept;
            if(y > y_threshold)
               is_lateral = 1;
            else
                is_midline = 1;
            end

        end
        
        function [is_midline, is_lateral] = get_right_region(obj,x,y)
            % Variable Initialization
            is_midline = 0;
            is_lateral = 0;
            
            X = [6.02115996400000, 0.284948655000000, -4.49482169800000];
            Y = [-4.45938718700000, -5.47913021000000, -5.83124149800000];
            [coefficients] = polyfit(X, Y, 1);
            slope = coefficients(1);
            intercept = coefficients(2);

            % Check if we are part of the three points
            for i=1:length(X)
               if(x == X(i))
                   is_midline = 1;
                   is_lateral = 1;
                   return;
               end
            end

            %Check if we are lateral and midline
            y_threshold = slope*x + intercept;
            if(y < y_threshold)
                is_lateral = 1;
            else
                is_midline = 1;
            end
        end
        
        % This function is to get non-overlapping windowed data
        function [windowed_data] = create_window(obj, data, window_size)
            window_size = window_size*obj.sampling_rate; % in points
            iterator = 1:window_size:(obj.length_recording - window_size);
            windowed_data = zeros(length(iterator),obj.number_channels,window_size);
            index = 1;
            for i = 1:window_size:(obj.length_recording - window_size)
                windowed_data(index,:,:) = data(:,i:i+window_size-1);
                index = index + 1;
            end
        end
        
        function [filtered_data] = filter_data(obj, data, frequency_band)
            
            %% Variable Initialization
            low_frequency = frequency_band(1);
            high_frequency = frequency_band(2);
            sampling_frequency = obj.sampling_rate;
            data = double(data);
            
            %% Design filter and filter the data
            [b,a]=butter(1, [low_frequency/(sampling_frequency/2) high_frequency/(sampling_frequency/2)]);
            filtered_data=filtfilt(b,a,data);
            
        end
    end
end

