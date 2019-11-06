function [bvp_struct, sc_struct,temp_struct] = comp_SQI_3(blood_volume_pulse,skin_conductance,temperature)
%% function data_in = comp_SQI(data_in)
% Function used to compute a data quality index for a measurement session
%                 
% Input: filename - including path if not in local directory.
%% Setting up variables
bvp_struct = struct();
sc_struct = struct();
temp_struct = struct();


%% 0 - Import BVP Model
% Clean existing variables in function workspace so it does not affect
% result consistency
clear_internal;

% Once the file is successfully read, save all the information in
% structure
% BVP signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bvp_unfilt = blood_volume_pulse;
bvp_original=smooth(hampel(bvp_unfilt, 15), 'moving');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

data_in.bvp= bvp_original;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.1 - Detrending filter
% Skin conductance signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_sc_original = skin_conductance;
data_in.sc = medfilt1(data_sc_original,75); %applymedian filter 
data_in.sc_temp=data_in.sc;
derr = diff(data_in.sc_temp); %derivative correction
z_der=zscore(derr);
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
filt_derr= cat(1,data_in.sc(1),derr);
data_in.sc= cumsum(filt_derr);

% Skin Temperature signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_skt_original = temperature;
data_in.skt= medfilt1(data_skt_original,1);


%set up placeholders for SQI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sc_sqi= ones(1, length(data_in.sc));
sc_sqi=sc_sqi';
temp_sqi= ones(1, length(data_in.skt));
temp_sqi=temp_sqi';

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

mean_sc_sqi=sum(sc_sqi.*weight_sc')/(sum(weight_sc));
mean_temp_sqi=sum(temp_sqi.*weight_skt')/(sum(weight_skt));

BVP_filt = data_in.bvp;
SC_filt = data_in.sc;
TMP_filt = data_in.skt;

BVPSCORE=mean(bvp_sqi_new);
SCSCORE=mean_sc_sqi;
TMPSCORE=mean_temp_sqi;

SCSQI = sc_sqi.*weight_sc';
TMPSQI = temp_sqi.*weight_skt';
BVPSQI = bvp_sqi_new;

bvp_struct.filt = BVP_filt;
bvp_struct.score = BVPSCORE;
bvp_struct.sqi = BVPSQI;

sc_struct.filt = SC_filt;
sc_struct.score = SCSCORE;
sc_struct.sqi = SCSQI;

temp_struct.filt = TMP_filt;
temp_struct.score = TMPSCORE;
temp_struct.sqi = TMPSQI;
