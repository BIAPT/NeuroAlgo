function [c_coeff, norm_average_c_coeff] = undirected_weighted_clustering_coefficient(matrix,null_networks)
%CLUSTERING_COEFFICIENT Will calculate the clusterig coefficient for th
%binary matrix
%   matrix: a N*N weighted square matrix
%   null_networks: 3d matrix containing pre-made null_networks
                
    %% Find Clustering coefficient
    c_coeff = clustering_coef_wu(matrix);  
    
    %% Calculate the characteristic path length for each null_matrix and average them
    [number_null_network, ~, ~] = size(null_networks);
    null_network_c_coeff = zeros(length(c_coeff),number_null_network);
    for i = 1:number_null_network
        null_w_matrix = squeeze(null_networks(i,:,:));
        null_network_c_coeff(:,i) = clustering_coef_wu(null_w_matrix);
    end
    avg_null_network_c_coeff = mean(null_network_c_coeff,2);
    
    norm_average_c_coeff = nanmean(c_coeff)/nanmean(avg_null_network_c_coeff); % weighted clustering coefficient
end

