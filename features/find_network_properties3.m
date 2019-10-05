function find_network_properties3

%   This function defines a network like Joon's paper, but normalizes
%   properties according to random networks

samp_freq = 250;
network_thresh = 0.05; %vary to see how stable our results are
win = 10;   % number of seconds of EEG window
% total_length = 300;    % total number of seconds of EEG epoch


for subject = 5
    

     Larray = zeros(1,floor(total_length/win)); %path length
     Carray = zeros(1,floor(total_length/win)); %clustering coefficient
     geffarray = zeros(1,floor(total_length/win)); %global efficiency
     bswarray = zeros(1,floor(total_length/win)); %small worldness
     Qarray = zeros(1,floor(total_length/win)); %modularity

    
    for bp = 4
        
    
        for state = 1:3
            
        
            state
%           EEG = pop_loadset('filename', [sname statename '.set'],'filepath',['F:\McDonnell Foundation study\University of Michigan\Anesthesia\' sname '\Resting state analysis']);
            EEG = pop_loadset('filename', [sname statename '.set'],'filepath','C:\Users\Danielle\OneDrive - McGill University\Research\BIAPT Lab\DOC\Motif paper\WSAS09\DATA\5 min segments\');

                
            [dataset, com, b] = pop_eegfiltnew(EEG, lp, hp);    
            filt_data = dataset.data';
        
            b_charpath = zeros(1,floor(total_length/win));
            b_clustering = zeros(1,floor(total_length/win));
            b_geff = zeros(1,floor(total_length/win));
            bsw = zeros(1,floor(total_length/win));
            Q = zeros(1,floor(total_length/win));
            
            for i = 1:(floor((length(filt_data))/(win*samp_freq)))
                
%                 EEG_seg = filt_data((i-1)*win*samp_freq + 1:i*win*samp_freq, EEG_chan);      % Only take win seconds length from channels that actually have EEG
                EEG_seg = filt_data((i-1)*win*samp_freq + 1:i*win*samp_freq, :);
                
                PLI = w_PhaseLagIndex(EEG_seg); %weighted PLI
                      
                A = sort(PLI);
                B = sort(A(:));
                C = B(1:length(B)-length(EEG_chan)); % Remove the 1.0 values from B (correlation of channels to themselves)
            
                index = floor(length(C)*(1-network_thresh)); %top network_thresh% of data
                thresh = C(index);  % Values below which the graph will be assigned 0, above which, graph will be assigned 1
            
            
            % Create a (undirected, unweighted) network based on top network_thresh% of PLI connections    
            for m = 1:length(PLI)
                for n = 1:length(PLI)
                    if (m == n)
                        b_mat(m,n) = 0;
                    else
                        if (PLI(m,n) > thresh)
                            b_mat(m,n) = 1;
                        else
                            b_mat(m,n) = 0;
                        end
                    end
                end
            end          
                
                % Find average path length
                               
                D = distance_bin(b_mat);
                [b_lambda,geff,~,~,~] = charpath(D,0,0);   % binary charpath
                [W0,R] = null_model_und_sign(b_mat,10,0.1);    % generate random matrix
                
                  % Find clustering coefficient

                C = clustering_coef_bu(b_mat);  
                
                % Find properties for random network
                
                [rlambda,rgeff,~,~,~] = charpath(distance_bin(W0),0,0);   % charpath for random network
                rC = clustering_coef_bu(W0); % cc for random network
                                  
                b_clustering(i) = nanmean(C)/nanmean(rC); % binary clustering coefficient
                b_charpath(i) = b_lambda/rlambda;  % charpath
                b_geff(i) = geff/rgeff; % global efficiency
                
                bsw(i) = b_clustering/b_charpath; % binary smallworldness
                
                [M,modular] = community_louvain(b_mat,1); % community, modularity
                Q(i) = modular;
                
            end
            
             Larray(state,:) = b_charpath(1,1:floor(total_length/win)); 
             Carray(state,:) = b_clustering;
             geffarray(state,:) = b_geff;
             bswarray(state,:) = bsw;
             Qarray(state,:) = Q;

        end
        
    end
    
end

 %figure; plot(Lnorm)
                
