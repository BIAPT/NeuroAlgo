function [r_wpli, r_labels, r_regions, r_location] = reorder_channels(wpli, location,cassette)
%REORDER CHANNELS take a wPLI matrix and a channels location struct and
%reorder the channels (will also implicitly filter because it is using
%scalp only channels file
    
    % Save the original directory and move to the other path
    channel_order = readtable(cassette);
    
    % Convert all location to the right name if we have biapt_egi129
    if strcmp(cassette, 'biapt_egi129.csv')
        convertion_table = readtable('biapt_egi129_convertion.csv');
        for i = 1:height(convertion_table)
            label = convertion_table.egi_naming_region{i};
            index = get_index_label(location, label);
            
            % If the index is not there then we are good we skip it
            if index == 0 
               continue 
            end
            
            % We convert that label to the right naming scheme
            convertion_label = convertion_table.egi_naming_letter{i};
            location(index).labels = convertion_label;
        end
    end
    
    % Fetch the correct channels location information
    [num_location, labels, regions] = get_num_location(location, channel_order);
    
    % Init the return data structure
    r_wpli = zeros(num_location, num_location);
    r_labels = labels;
    r_regions = regions;
    r_location = [];
    
    % Iterate over all the channels combination (num_channels *
    % num_channels)
    for l1 = 1:length(labels)
       label_1 = labels{l1};
       index_1 = get_index_label(location, label_1);
       
       % index_1 doesn't exist we skip this iteration
       if(index_1 == 0)
          continue; 
       end
       
       r_location = [r_location location(index_1)];
        for l2 = 1:length(labels)
            label_2 = labels{l2};
            index_2 = get_index_label(location, label_2);
            
            % If one of the channel doesn't exist we just skip this
            % iteration
            if(index_2 == 0)
                continue 
            end
            
            r_wpli(l1,l2) = wpli(index_1, index_2);
        end
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
