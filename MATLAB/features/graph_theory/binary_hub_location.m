function [hub_location, weights] = binary_hub_location(b_wpli, location)
%BETWEENESS_HUB_LOCATION select a channel which is the highest hub based on
%betweeness centrality and degree
% input:
% b_wpli: binary matrix
% location: 3d channels location
% output:
% hub_location: This is a number between 0 and 1, where 0 is fully
% posterior and 1 is fully anterior
% weights: this is a an array containing weights of each of the channel in
% the order of the location structure

    %% 1.Calculate the degree for each electrode.
    degrees = degrees_und(b_wpli);
    norm_degree = (degrees - mean(degrees)) / std(degrees);
    a_degree = 1.0;
    
    %% 2. Calculate the betweeness centrality for each electrode.
    bc = betweenness_bin(b_wpli);
    norm_bc = (bc - mean(bc)) / std(bc);
    a_bc = 1.0;
    
    
    %% 3. Combine the two Weightsmetric (here we assume equal weight on both the degree and the betweeness centrality)
    weights = a_degree*norm_degree + a_bc*norm_bc;
    
    %% Obtain a metric for the channel that is most likely the hub epicenter
    [~, channel_index] = max(weights);
    hub_location = threshold_anterior_posterior(channel_index, location);

end

function [normalized_value] = threshold_anterior_posterior(index,channels_location)
%THRESHOLD_ANTERIOR_POSTERIOR Summary of this function goes here
%   Detailed explanation goes here

    current_x = channels_location(index).X;
    
    all_x = zeros(1,length(channels_location));
    for i = 1:length(channels_location)
       all_x(i) = channels_location(i).X; 
    end
    
    min_x = min(all_x);
    max_x = max(all_x);
    
    normalized_value = (current_x - min_x)/(max_x - min_x);
end

