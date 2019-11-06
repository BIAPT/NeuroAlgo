function [data_Seg] = sqi_bvp(data_in, bvpModel)
% Usage: bvp_sqi = sqi_bvp(data_in)

% input: data_in : structure containing, time, bvp, sc and skt signals from TPS sensor.
%                 
% Output: data_Seg : data_in with added bvp SQI element.
%
% Coded by: Pascal Fortin
% Supervised by: Stefanie Blain-Moraes, Jeremy R. Cooperstock
% McGill University, Montreal, Canada
% 
% Detailed description
% bvp signal quality uses the following features
%   1. Heart rate Can you extract a decent heart rate (between 30 and 130
%   BPM) (segment bvp)
%   2. Distance from Model (thresholds). 
%   3. Standard deviation on the dynamic time warping residual signal

%% 0 - Loading and formatting Data
% Detrend and Denoise signals
data = preprocess_sqi(data_in);

% Sampling frequency
Fs = 75;
%% 1 - segment
% Segment the signals using bvp signal.
data_Seg = segment_bvp_sqii(data);

    array = [];
    % for all segments found. For all the measurement if no segments were
    % found.
    for n=1:length(data_Seg)
    %   Estimate heart rate from pulse duration
        data_Seg{n}.bpm = (Fs*60)/length(data_Seg{n}.bvp);

    %   Linearly remap bvp values between 0 and 1
        data_Seg{n}.bvp_temp = (data_Seg{n}.bvp-min(data_Seg{n}.bvp))/(max(data_Seg{n}.bvp)-min(data_Seg{n}.bvp));

    %   Compute dynamic time warping distance and warping path
        [data_Seg{n}.dtwdist, data_Seg{n}.dtwix, data_Seg{n}.dtwiy] = dtw(data_Seg{n}.bvp_temp, bvpModel, 30);

    %   Compute residual between aligned time sequences
        TempResidue = data_Seg{n}.bvp_temp(data_Seg{n}.dtwix) - bvpModel(data_Seg{n}.dtwiy);

    %   Split the "continuous" residue signal into 20 equal length time segments
        data_Seg{n}.dtwResBins = binit(TempResidue, 20);
        data_Seg{n}.dtwResSum = sum(abs(data_Seg{n}.dtwResBins));
        data_Seg{n}.dtwResBinsMean = mean(data_Seg{n}.dtwResBins);
        data_Seg{n}.dtwResBinsStd = std(data_Seg{n}.dtwResBins);

    %   Give 0 as a default bvp SQI.
        data_Seg{n}.bvp_SQI = 1;
%         
%     %   If heart rate is valid, consider shape of the pulse
%         if data_Seg{n}.bpm <= 130 && data_Seg{n}.bpm >= 30 
%             % Using the summ of dtwResBins, std and mean. -9 is arbitrary
%             % and was chosen looking at the values as OK signals were at
%             % around 9.
%             % 0.25 was chosen arbitrarily to accentuate small variations in
%             % the summation. Values might have to be fine tuned...
%             data_Seg{n}.bvp_SQI = 1 - 0.7*exp(-0.2*(data_Seg{n}.dtwResSum + data_Seg{n}.dtwResBinsStd + data_Seg{n}.dtwResBinsMean - 9));
%         else
%             temp_index = 1 - 0.5*exp(-0.2*(data_Seg{n}.dtwResSum + data_Seg{n}.dtwResBinsStd + data_Seg{n}.dtwResBinsMean - 9));
%             data_Seg{n}.bvp_SQI = 0.75*temp_index;
%         end
%         
%         % Constrain SQI between 0 and 1
%         if data_Seg{n}.bvp_SQI < 0
%             data_Seg{n}.bvp_SQI = 0;
%         elseif data_Seg{n}.bvp_SQI > 1
%             data_Seg{n}.bvp_SQI = 1;
%         end       
    end
end