classdef Recording
    %Recording Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
        filt_data;
        length_recording;
        sampling_rate;
        number_channels;
        channels_location;
        creation_date;
        
        window_size;
        step_size;
        max_number_window;
        current_window;
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
            
            obj.filt_data = [];
            
            % Precompute some label to ease up the analysis that require
            % channels at specific location
            if(~isempty(channels_location))
                obj = obj.compute_region_label();
                obj = obj.compute_lobe();
            end
        end
        
        %% Helper Function
        
        function obj = compute_lobe(obj)
            %label channels as F,C,P,O or T
            
            %includes 10-20 and EGI labels (e.g. E11 = Fz)
            F = {'E1','E2','E3','E4','E5','E9','E10','E11','E12',...
                'E15','E16','E18','E19','E20','E22','E23','E24','E26',...
                'E27','E28','E32','E33','E34','E116','E117','E118','E122','E123',...
                'E124','Fp2','Fz','Fp1','F3','F7','F8','F4'};
            
            C = {'E6','E7','E13','E29','E30','E31','E35','E36','E37',...
                'E41','E42','E47','E53','E54','E55','E79','E80','E86',...
                'E87','E93','E98','E103','E104','E105','E106','E110',...
                'E111','E112','E1001','C3','C4','Cz'};
            
            P = {'E51','E52','E58','E59','E60','E61','E62','E66','E67',...
                'E71','E72','E76','E77','E78','E84','E85','E91','E92','E96','E97',...
                'P3','T5','Pz','P4','T6'};
            
            O = {'E64','E65','E69','E70','E74','E75','E82','E83','E89','E90','E95',...
                'O1','Oz','O2'};
            
            T = {'E38','E39','E40','E44','E45','E46','E50','E57','E100','E101','E102',...
                'E108','E109','E114','E115','E121','T3','LM','RM','T4'};
            
            for i = 1:obj.number_channels
                x = obj.channels_location(i).labels;
                if any(strcmp(x,F))
                    obj.channels_location(i).lobe = 'F';
                elseif any(strcmp(x,C))
                    obj.channels_location(i).lobe = 'C';
                elseif any(strcmp(x,P))
                    obj.channels_location(i).lobe = 'P';
                elseif any(strcmp(x,O))
                    obj.channels_location(i).lobe = 'O';
                elseif any(strcmp(x,T))
                    obj.channels_location(i).lobe = 'T';
                end
            end
        end
        
        function  obj = compute_region_label(obj)
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
            [windowed_data] = create_sliding_window(obj, data, window_size, window_size);
        end
        
        % This function is to get overlapping windowed data
        function [windowed_data] = create_sliding_window(obj, data, window_size, step)
            window_size = window_size*obj.sampling_rate; % in points
            step = step*obj.sampling_rate;
            iterator = 1:step:(obj.length_recording - window_size);
            windowed_data = zeros(length(iterator),obj.number_channels,window_size);
            index = 1;
            for i = 1:step:(obj.length_recording - window_size)
                windowed_data(index,:,:) = data(:,i:i+window_size-1);
                index = index + 1;
            end
        end
        
        % These two functions are used when the size of the data doesn't
        % fit in RAM
        function obj = init_sliding_window(obj, window_size, step_size)
            obj.window_size = window_size*obj.sampling_rate;
            obj.step_size = step_size*obj.sampling_rate;
            obj.max_number_window = length(1:obj.step_size:(obj.length_recording - obj.window_size));
            if obj.max_number_window == 0 %happens if window size = length recording (i.e. if length of recording is a multiple of sampling rate)
                obj.max_number_window = 1;
            end
            obj.current_window = 1;
        end
        
        function [obj,windowed_data] = get_next_window(obj)
            i = obj.current_window;
            % here we decide if we slice the filtered data or the original
            % data
            if(isempty(obj.filt_data))
                windowed_data = obj.data(:,i:i+obj.window_size-1);
            else
                windowed_data = obj.filt_data(:,i:i+obj.window_size-1);
            end
            
            obj.current_window = obj.current_window + obj.step_size;
        end
        
        
        function [obj] = filter_data(obj, data, frequency_band)
            
            %% Variable Initialization
            low_frequency = frequency_band(1);
            high_frequency = frequency_band(2);
            sampling_frequency = obj.sampling_rate;
            obj.filt_data  = filter_bandpass(data, sampling_frequency, low_frequency, high_frequency);
        end
    end
end

