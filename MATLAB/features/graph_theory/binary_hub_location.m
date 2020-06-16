function [hub_location, weights] = binary_hub_location(b_wpli, location, a_degree, a_bc)
%BETWEENESS_HUB_LOCATION select a channel which is the highest hub based on
%betweeness centrality and degree
% input:
% b_wpli: binary matrix
% location: 3d channels location
% a_degree: weight to put on the degree for the definition of hub
% a_bc: weight to put on the betweeness centrality for the definition of
% hub
%
% output:
% hub_location: This is a number between 0 and 1, where 0 is fully
% posterior and 1 is fully anterior
% weights: this is a an array containing weights of each of the channel in
% the order of the location structure

    %% 1.Calculate the degree for each electrode.
    degrees = degrees_und(b_wpli);
    norm_degree = (degrees - mean(degrees)) / std(degrees);
    
    %% 2. Calculate the betweeness centrality for each electrode.
    bc = betweenness_bin(b_wpli);
    norm_bc = (bc - mean(bc)) / std(bc);
    
    
    %% 3. Combine the two Weightsmetric (here we assume equal weight on both the degree and the betweeness centrality)
    weights = a_degree*norm_degree + a_bc*norm_bc;
    
    %% Obtain a metric for the channel that is most likely the hub epicenter
    [~, channel_index] = max(weights);
    hub_location = threshold_anterior_posterior(channel_index, location);

end

function [normalized_value] = threshold_anterior_posterior(index,channels_location)
%THRESHOLD_ANTERIOR_POSTERIOR This function will squash the channels in the
%direction of the anterior-posterior line and will set the most posterior
%index to 0 and the anterior most anterior index to 1
%   To do so it takes the index of the channel we want to normalize in the
%   posterior-anterior direction and the channels location for where it
%   came from. It then will find the value this channel should have.
% input:
% index: index of the channel to normalize between 0 and 1
% channels_location: 3D channel data structure

    % Get the X index of the current channels
    current_x = channels_location(index).X;
    
    % Accumulate all the Xs index for the channels locations
    all_x = zeros(1,length(channels_location));
    for i = 1:length(channels_location)
       all_x(i) = channels_location(i).X; 
    end
    
    % Normalize the current value of x between the min coordinate we have
    % in the headset and the maximum
    min_x = min(all_x);
    max_x = max(all_x);
    normalized_value = (current_x - min_x)/(max_x - min_x);
end

