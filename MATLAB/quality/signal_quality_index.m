function [ sc_sqi, temp_sqi] = signal_quality_index(skin_conductance, temperature)
%% function data_in = comp_SQI(data_in)
% Function used to compute a data quality index for a measurement session
%                 
% Input: filename - including path if not in local directory.

    % Clean existing variables in function workspace so it does not affect
    % result consistency
    clear_internal;
    
    %% 1.1 - Detrending filter
    % Skin conductance signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    skin_conductance = medfilt1(skin_conductance,75); %applymedian filter 
    derr = diff(skin_conductance); %derivative correction
    z_der = zscore(derr);
    for k=11:length(derr)-10
        
        if z_der(k) >5 % corrects for steep positive slopes. 
            derr(k)= median(derr(k-10:k+10));
        end
        
        % and correct for steep negative slopes. value different than positive
        % threshold. More lenient in steep decreases than increases
        if z_der(k)<-3 
           derr(k)= median(derr(k-10:k+10));
        end
        
    end
    
    filt_derr = cat(1,skin_conductance(1),derr);
    data_in.sc = cumsum(filt_derr);

    % Skin Temperature signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_in.skt = medfilt1(temperature,1);

    %set up placeholders for SQI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sc_sqi= ones(1, length(data_in.sc));
    sc_sqi=sc_sqi';
    
    temp_sqi= ones(1, length(data_in.skt));
    temp_sqi=temp_sqi';
    
    %% 2- SKIN CONDUCTANCE Signal Quality Index
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    W = 30;
    L = length(data_in.sc);  
    for l1 = 1:15:L-W+1
        l2=l1-1+W;
        dff= std(data_in.sc(l1:l2));
        sc_sqi(l1:l2)=sc_sqi(l1:l2)*exp(-0.1*dff); 
        if max(diff(data_in.sc(l1:l2))) > 3 
            sc_sqi(l1:l2) = 0.4*sc_sqi(l1:l2);
        end  
    end
    %the below code must match any changes made above.
    if mod(L, 2)~=0
       l1=L-W;
       l2=L;
       dff= std(data_in.sc(l1:l2));
       sc_sqi(l1:l2)=sc_sqi(l1:l2)*exp(-0.1*dff);
        if max(diff(data_in.sc(l1:l2))) > 3
            sc_sqi(l1:l2) = 0.4*sc_sqi(l1:l2);
        end  

    end

    W = 120; %identifiy flat lines and decrease their signal quality
    for l1 = 1:30:L-W+1 
        l2=l1-1+W;
            if max(abs(diff(data_in.sc(l1:l2)))) <= 0.001
                sc_sqi(l1:l2) = 0.1*sc_sqi(l1:l2);
            end 
    end

    for j=1:length(sc_sqi) %identify values out of normal range 
        if data_in.sc(j) <= 0.02
            sc_sqi(j) = 0;
        end
         if data_in.sc(j) > 20
            sc_sqi(j) = 0.65;
         end
         if data_in.sc(j) > 30
            sc_sqi(j) = 0;
        end
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 3- SKIN TEMPERATURE Signal Quality Index
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    W = 50;
    L = length(data_in.skt);  
    for l1 = 1:25:L-W+1 %value betweeen 1 and L is half the window size   
        l2=l1-1+W;
        dff= std(data_in.skt(l1:l2));
        temp_min = min(data_in.skt(l1:l2));
        temp_maxmin = max(data_in.skt(l1:l2))-min(data_in.skt(l1:l2));
        temp_sqi(l1:l2)=temp_sqi(l1:l2)*exp(-0.20*dff); %sensitivity to SD
        if temp_min < 15 %identify out of range values 
                temp_sqi(l1:l2) = 0.50*temp_sqi(l1:l2); 
        end
        if max(abs(diff(data_in.skt(l1:l2)))) <= 0.0001 %identify flat lines 
                temp_sqi(l1:l2) = 0.50*temp_sqi(l1:l2);
        end    
         if abs(temp_maxmin) > 4 %identify steep increases/decreases
                temp_sqi(l1:l2) = 0.3*temp_sqi(l1:l2);
         end

    end

    if mod(L, 2) ~=0 && L>50
        l1=L-W;
        l2=L;
        dff= std(data_in.skt(l1:l2));
        temp_min = min(data_in.skt(l1:l2));
        temp_maxmin = max(data_in.skt(l1:l2))-min(data_in.skt(l1:l2));
        temp_sqi(l1:l2)=temp_sqi(l1:l2)*exp(-0.20*dff);

        if temp_min < 15
            temp_sqi(l1:l2) = 0.50*temp_sqi(l1:l2);
        end
        if max(abs(diff(data_in.skt(l1:l2)))) < 0.0001
            temp_sqi(l1:l2) = 0.50*temp_sqi(l1:l2);
        end     
        if abs(temp_maxmin) > 4
            temp_sqi(l1:l2) = 0.3*temp_sqi(l1:l2);
        end

    end

    %% 4 - Make a decision based on the three signal quality indexes 

    for j=1:length(sc_sqi)
        if sc_sqi(j) <= 0.5
            weight_sc(j)=2;
        else
            weight_sc(j)= 1;
        end
    end

    for j = 1:length(temp_sqi)
        if temp_sqi(j) <= 0.5
            weight_skt(j)=2;
        else
            weight_skt(j)=1;
        end
    end

    sc_sqi = sc_sqi.*weight_sc';

    temp_sqi = temp_sqi.*weight_skt';
end
