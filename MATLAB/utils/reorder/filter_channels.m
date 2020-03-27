function [r_vector, r_location] = filter_channels(vector, location)
%REORDER CHANNELS take a wPLI matrix and a channels location struct and
%reorder the channels (will also implicitly filter because it is using
%scalp only channels file
    
    % Save the original directory and move to the other path
    channel_order = readtable('biapt_egi129.csv');
    
    % Fetch the correct channels location information
    [num_location, labels] = get_num_location(location, channel_order);
    
    % Init the return data structure
    r_vector = zeros(1, num_location);
    r_location = [];
    
    % Iterate over all the channels combination (num_channels *
    % num_channels)
    for l = 1:length(labels)
        label_i = labels{l};
        index = get_index_label(location, label_i);

        % If one of the channel doesn't exist we just skip this
        % iteration
        if(index == 0)
           continue 
        end

        r_vector(l) = vector(index);
        r_location = [r_location, location(index)];
    end
end


function [index] = get_index_label(location, target)
% GET INDEX LABEL will fetch the index of a given label (target) inside the
% location data structure

    index = 0;  
    for l = 1:length(location)
       label = location(l).labels;
       if(strcmp(label,target))
           index = l;
            return 
       end
    end
    
end

function [num_location, labels, regions] = get_num_location(location, total_location)
%GET NUM LOCATION will fetch the stats for the wPLI matrix that match the
%total channels location inside the csv file. This will prevent case where
%there is a channel missing in the data, but the size is still the size of
%total_location

    % Init the return data structure
    num_location = 0;
    labels = {};
    regions = {};
    
    % Iterate through all channels in total location and check if it exist
    % in the current location
    for i = 1:height(total_location)
       label = total_location(i,1).label{1};
       region = total_location(i,2).region{1};

       % If it exist we add information about this region in the return
       % data structure
       if(get_index_label(location, label) ~= 0)
           num_location = num_location + 1;
           labels{end+1} = label;
           regions{end+1} = region;
       end
    end
end
