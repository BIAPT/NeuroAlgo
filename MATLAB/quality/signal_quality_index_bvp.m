function [bvp_struct] = signal_quality_index_bvp(bvp)
%% function data_in = comp_SQI(data_in)
% Function used to compute a data quality index for a measurement session
%                 
% Input: filename - including path if not in local directory.
    %% Setting up variables
    bvp_struct = struct();

    %% 0 - Import BVP Model
    % Clean existing variables in function workspace so it does not affect
    % result consistency
    clear_internal;

    % Once the file is successfully read, save all the information in
    % structure
    % BVP signal
    bvp_original = smooth(hampel(bvp, 15), 'moving');
    
    derr = diff(bvp_original);
    z_der=zscore(derr);
    for k=11:length(derr)-10
        if z_der(k) >4
            derr(k)= median(derr(k-10:k+10));
        end
        if z_der(k)<-4
           derr(k)= median(derr(k-10:k+10));
        end
    end

    filt_derr= cat(1,bvp_original(1),derr);
    bvp_original= cumsum(filt_derr);

    data_in.bvp = bvp_original;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% set up FFT values and calculate fft for data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    L = length(data_in.bvp);             % Length of signal
    Fs = 75;            % Sampling frequency                    
    f = (0:L-1)*(Fs/L);
    o=1;
    count_d=0;
    Y = fft(data_in.bvp());
    P2 = abs(Y/L);
    P1 = abs(Y).^2/L;
    P1_vec(o,:) = P1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 1- BVP Signal Quality Index
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    W = 400;
    v = floor(W/2);

    for l1 = 1:v:L-W+1
        l2=l1-1+W;
        dff= std(data_in.bvp(l1:l2));
        sub= max(abs(diff(data_in.bvp(l1:l2))));
        msub = mean(abs(diff(data_in.bvp(l1:l2))));
        dmsub = mean(abs(diff(diff(data_in.bvp(l1:l2)))));
        if dff < 0.001
            count_d=60+count_d;
        elseif dff < 0.005
            count_d=30+count_d;
        elseif dff < 0.01
            count_d=20+count_d;
        elseif dff < 0.05
            count_d=15+count_d;
        elseif dff < 0.08
            count_d=0.5+count_d;
        end
        
        if sub < 0.005
            count_d=50+count_d;
        elseif sub < 0.01
            count_d=1+count_d;
        end
        
        if msub < 0.00005
            count_d=20+count_d;
        end
        
        if dmsub < 0.00005
            count_d=30+count_d;
        elseif dmsub < 0.0005
            count_d=20+count_d;
         end
    end

    % Compute mean FFT
    if length(P1_vec(:,1)) ==1
        mean_P1=P1_vec;
    else
    mean_P1= nanmean(P1_vec);
    end
    [pks,locs]= findpeaks(mean_P1,'MinPeakProminence',0.75);
    bool=0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    max_good=0;
    % loop to find good and bad peaks: ratio between the two
    if length(pks)~=0   
    for i=1:length(pks)
        if f(locs(i)) >=0.6  && f(locs(i)) <=2.5
            bool =1;
        end
    end

    good=mean_P1(find(f<2.5 & f >0.6));
    if max(max_good) >10
    for i=1:length(good)
        m_fact=5*(floor(good(i)/10));

        if  m_fact==0
             m_fact=1;
        end
        good(i) = m_fact*good(i);

    end

    temp_bad= sum((mean_P1(find(f<0.6 & f>0.3))));
    temp_bad_2= sum((mean_P1(find(f>2.5 & f <35))));
    temp_good= 1.1*sum((good));
    else
        for i=1:length(good);
        m_fact=10;
        good(i) = m_fact*good(i);
        end
        temp_bad= sum((mean_P1(find(f<0.6 & f>0.15))));
        temp_bad_2= sum((mean_P1(find(f>2.5 & f <35))));
        temp_good= 1.2*sum((good));
    end

    % add penalties for other artifacts
    if bool ==1
        bvp_sqi_new= temp_good/(temp_good+temp_bad+temp_bad_2);
    else
        bvp_sqi_new=0;
    end
    if count_d >0
         bvp_sqi_new= bvp_sqi_new -(0.01*count_d);
    end

    else
        bvp_sqi_new= 0;
    end


    % Constrain SQI between 0 and 1
    if bvp_sqi_new < 0
        bvp_sqi_new = 0;
    elseif bvp_sqi_new > 1
        bvp_sqi_new = 1;
    end    

    bvp_sqi_new = bvp_sqi_new*ones(length(data_in.bvp),1);
    
    BVP_filt = data_in.bvp;

    BVPSCORE=mean(bvp_sqi_new);
    
    BVPSQI = bvp_sqi_new;

    bvp_struct.filt = BVP_filt;
    bvp_struct.score = BVPSCORE;
    bvp_struct.sqi = BVPSQI;


end
