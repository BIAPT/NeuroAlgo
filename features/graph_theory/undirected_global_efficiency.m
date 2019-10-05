function [g_efficiency,norm_g_efficiency,avg_path_length,norm_avg_path_length] = undirected_global_efficiency(matrix,t_level,number_null_network, bin_swaps, weight_frequency)
%UNDIRECTED GLOBAL EFFICIENCY will calculate the undirected global
%efficiency and path length for connectivity matrices like wpli
%   matrix:
%   t_level:
%   number_null_network:
%   bin_swaps:
%   weight_frequency
    %% Binarize and Threshold the matrix
    b_matrix = binarize_matrix(threshold_matrix(matrix,t_level));
    
    %% Create random null network
    [num_row, num_col] = size(b_matrix); % These should be the same
    null_matrices = zeros(number_null_network,num_row, num_col);
    for i = 1:number_null_network
        disp(i)
        [null_matrix,~] = null_model_und_sign(b_matrix,bin_swaps,weight_frequency);    % generate random matrix
        null_matrices(i,:,:) = null_matrix; % store all null matrix
    end
    
    %% Calculate the characteristic path length
    input_distance = distance_bin(b_matrix);
    [avg_path_length,g_efficiency,~,~,~] = charpath(input_distance,0,0);   % binary charpath
    
    %% Calculate the characteristic path length for each null_matrix and average them
    null_matrices_avg_path_length = zeros(1,number_null_network);
    null_matrices_g_efficiency = zeros(1,number_null_network);
    for i = 1:number_null_network
        null_b_matrix = null_matrices(i,:,:);
        null_input_distance = distance_bin(null_b_matrix);
        [null_matrix_avg_path_length,null_matrix_g_efficiency,~,~,~] = charpath(null_input_distance,0,0);   % binary charpath    
        null_matrices_avg_path_length(i) = null_matrix_avg_path_length;
        null_matrices_g_efficiency(i) = null_matrix_g_efficiency;
    end
    % Calculate mean null path length and mean global efficiency
    null_avg_path_length = mean(null_matrices_avg_path_length);
    null_g_efficiency = mean(null_matrices_g_efficiency);
    
    %% Normalizing average path length and global effiency
    norm_g_efficiency = g_effiency/null_g_efficiency;
    norm_avg_path_length = avg_path_length/null_avg_path_length;
end

