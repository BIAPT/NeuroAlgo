function [avg_pe_frontal,avg_pe_posterior] = permutation_entropy(eeg_data,eeg_info,parameters,frontal_mask,posterior_mask)
%PERMUTATION_ENTROPY calculate the permutation entropy for the frontal and
%posterior channels and return an average of both values
%   Input:
%       eeg_data: data to calculate the measures on
%       eeg_info: headset information
%       parameters: variables data as inputed by the user
%       frontal_mask: boolean mask for the frontal electrodes
%       posterior_mask: boolean mask for the posterior electrode
%   Output:
%       avg_pe_frontal: singular value representing pe of frontal
%       electrodes
%       avg_pe_posterior: singular value representing pe of posterior
%       electrodes

    %% Apply boolean mask
    frontal_eeg = eeg_data(frontal_mask == 1,:)';
    posterior_eeg = eeg_data(posterior_mask == 1,:)';

    %% Extract parameters from data structure
    embedding_dimension = parameters.embedding_dimension;
    time_delay = parameters.time_delay;
    
    %% Calculate permutation entropy
    % Here we use code from our collaborator (in lib/EEGsonic_function/features/helper
    [~,frontal_pe] = permutation_entropy_mv(frontal_eeg,embedding_dimension,time_delay); 
    [~,posterior_pe] = permutation_entropy_mv(posterior_eeg,embedding_dimension,time_delay);
  
    %% Average the values received
    avg_pe_frontal = mean(frontal_pe);
    avg_pe_posterior = mean(posterior_pe);
end

