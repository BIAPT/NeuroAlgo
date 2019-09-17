function [permutation_entropy, norm_permutation_entropy]=permutation_entropy_mv(data, embedding_dimension, time_lag)
% permutation entropy for multivariate signals (just a repetition of calculation for multi-channel signals)
% 2018.1.19. Heonsoo Lee
% 2018.12.31 Yacine Mahdid (Refactored for readability)

% Input:
%   data: each column must be a time series
%   embedding_dimension: embedding dimension, or pattern size
%   time_lag: time lag
%
% Output:
%   permutation_entropy: (unnormalized) permutation entropy
%   norm_permutation_entropy: normalized permutation entropy

    %% Initialization of Variables
    numpat=factorial(embedding_dimension); % number of patterns
    denom=log2(numpat); % normalization factor
    Ddata=delay_reconstruction(data, time_lag, embedding_dimension); % delay reconstruction
    [~,number_channels]=size(data); % get number of channels
   
    %% Pre-allocation of Output
    permutation_entropy = zeros(1,number_channels);
    norm_permutation_entropy = zeros(1,number_channels);
    
    for c=1:number_channels
        %% real value -> symoblic pattern
        udata=zeros(size(Ddata(:,:,c),1), 1);
        [~, Ddata_sort]=sort(Ddata(:,:,c),2);
        for i=1:embedding_dimension
            udata=udata+Ddata_sort(:,i)*10^(round(embedding_dimension/2)-i)'; % *** double precision: 10^-16
        end
        %% probability
        [u_patterns, ~]=unique(udata); % find unique patterns
        u_len=length(u_patterns); % # of unique patterns
        p=zeros(1, numpat);
        for u=1:u_len
            ind=find(udata==u_patterns(u));
            p(u)=length(ind)/size(udata,1);
        end
        permutation_entropy(1,c)=-sum(p.*log2(p+eps));
        norm_permutation_entropy(1,c)=permutation_entropy(c)./denom;
        clear p;
    end
end



