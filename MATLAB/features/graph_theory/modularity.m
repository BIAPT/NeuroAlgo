function [community] = modularity(b_matrix)
%MODULARITY Summary of this function goes here
%   b_matrix: a N*N binary square matrix
%   null_networks: 3d matrix containing pre-made null_networks
%   gamma: if large will detect smaller module, if small will detect larger
%   module

    [~,community] = community_louvain(b_matrix); % community, modularity
end


