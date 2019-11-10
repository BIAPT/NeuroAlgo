function [null_networks] = generate_null_networks(matrix, number_null_network, bin_swaps, weight_frequency)
%GENERATE_NULL_NETWORK Summary of this function goes here
%   Detailed explanation goes here
    
    %% Create random null network
    [num_row, num_col] = size(matrix); % These should be the same
    null_networks = zeros(number_null_network,num_row, num_col);
    
    % Here we use multi-core to speed up the analysis (this is a
    % bottleneck)
    parfor i = 1:number_null_network
        [null_matrix,~] = null_model_und_sign(matrix,bin_swaps,weight_frequency);    % generate random matrix
        null_networks(i,:,:) = null_matrix; % store all null matrix
    end

end

