function [intensity, coherence, frequency, norm_intensity, norm_coherence, norm_frequency] = motif_3(network,number_rand_network, bin_swaps, weight_frequency)
%MOTIF_3    
    
    %% 1) Calculate the motif for our network of interest.
    [intensity,coherence,frequency] = motif3funct_wei(network);
    
    % Create the matrices
    rand_intensity = zeros(number_rand_network,13,length(network));
    rand_coherence = zeros(number_rand_network,13,length(network));
    rand_frequency = zeros(number_rand_network,13,length(network)); 
    
    % Create X random network using our network of interest 
    parfor i = 1:number_rand_network
        [rand_network,~] = null_model_dir_sign(network,bin_swaps,weight_frequency);
        % Calculate the motif for the X random network. (BOTTLE NECK)
        [rand_intensity(i,:,:),rand_coherence(i,:,:),rand_frequency(i,:,:)] = motif3funct_wei(rand_network);
    end
    
    %% 4) Calculate the Z score for each motifs
    
    % Might want to refactor this
    cat_rand_intensity = rand_intensity(1,:,:);
    cat_rand_coherence = rand_coherence(1,:,:);
    cat_rand_frequency = rand_frequency(1,:,:);
    for i = 2:number_rand_network
        cat_rand_intensity = cat(3,cat_rand_intensity,rand_intensity(i,:,:));
        cat_rand_coherence = cat(3,cat_rand_coherence,rand_coherence(i,:,:));
        cat_rand_frequency = cat(3,cat_rand_frequency,rand_frequency(i,:,:));
    end
    cat_rand_intensity = squeeze(cat_rand_intensity)';    
    cat_rand_coherence = squeeze(cat_rand_coherence)';    
    cat_rand_frequency = squeeze(cat_rand_frequency)';

    norm_intensity = (mean(intensity') - mean(cat_rand_intensity) ./ std(cat_rand_intensity);    
    norm_coherence = (mean(coherence') - mean(cat_rand_coherence) ./ std(cat_rand_coherence);
    norm_frequency = (mean(frequency') - mean(cat_rand_frequency) ./ std(cat_rand_frequency);
    
end