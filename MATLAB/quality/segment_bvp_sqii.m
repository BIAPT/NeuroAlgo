function s_seg = segment_bvp(data_in)
% Usage s_seg = Segment_bvp(data_in)
% Takes a bvp signal recording, segment it in the number of pulses that are
% observables and detected in the sequence and returns a structure s_seg containing
% the estimated heart rate from the number of pulses, the BPM estimated from the
% duration of each peak (mean and 95% CI), and the segmented signals.
%
% input: data_in- Array of TPS measurements containing BVP, SC and SKT
%
% Output: s_seg - s_seg.full_signal - structure containing the full original signal
%                 s_seg.zc - index at which zero crossings are happening
%                 s_seg.ibs - 95% confidence interval on heart rate
%                 s_seg.hr.fe - heart rate computer over all of the segment
%                 s_seg.segment - cell-array containing all individual segments
%                 
% Coded by: Pascal Fortin
% Supervised by: Stefanie Blain-Moraes, Jeremy R. Cooperstock
% McGill University, Montreal, Canada
% 
% Detailed description
% 1. Over low-pass filter the BVP signal to remove all BVP signal notches (Cut-off 5Hz)
% 2. Find positive slope zero crossings of first derivative of the filtered signal using its second derivative
% 3. Clean points that belong to the same zero crossing
% 4. Consider data points between each pulse delimiter as a segment

%% 1 - Over low-pass filter the BVP signal
% BVP cut-off frequency
Fc = 5;
% Sampling Frequency
Fs = 75;

% BVP Normalized cut-off frequency
nFc = Fc/Fs;

% 3rd order low-pass filter with nFc
[ofb, ofa] = butter(3,nFc); 

% For each element in data_in
if isstruct(data_in)
    for k=1:length(data_in)
%         fprintf('IsStruct - Starting segmentation of session %i - ', k)
        % Filter the signal
        o_data.of_bvp = filtfilt(ofb, ofa, data_in(k).bvp);

        %% 2 - Find positive slope zero crossings of first derivative of the over filtered signal
        % First Derivative
        o_data.diff_of_bvp = diff(o_data.of_bvp);

        % find peaks in 1st derivative that match with zero crossings of 1st derivative.
        [PKS{k},LOCS{k},~,P{k}] = findpeaks(100*o_data.diff_of_bvp);
        idx_pks = find(P{k}>0.1);

        %% 2.5 - If No Segments were found, split based on time
        % Minimum heart rate is arbitrarily set to 25 BPM
        %     25 bpm = 512 samples/second* 60 second / 25 BPM = 1228smpls/bpm
        
        %% 3 - Split Segments
        % Split the segments using the found peaks on first derivative.
        
        if length(idx_pks)>1
            for n=1:length(LOCS{k}(idx_pks))-1
                s_seg{k,n}.t = data_in(k).t(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.bvp = data_in(k).bvp(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.sc = data_in(k).sc(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.skt = data_in(k).skt(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.pks = length(LOCS{k}(idx_pks));
            end
%             fprintf('Generated %i segments\n', n)
        else
%             disp('Could Not Identify segments in the Session')
                s_seg{1}.t = data_in.t;
                s_seg{1}.bvp = data_in.bvp;
                s_seg{1}.sc = data_in.sc;
                s_seg{1}.skt = data_in.skt;
                s_seg{1}.pks = 0;
        end
        
        
    end
    
elseif iscell(data_in)
        for k=1:length(data_in)
%             fprintf('IsCell - Starting segmentation of session %i - ', k)
            % Filter the signal
            o_data.of_bvp = filtfilt(ofb, ofa, data_in{k}.bvp);

            %% 2 - Find positive slope zero crossings of first derivative of the over filtered signal
            % First Derivative
            o_data.diff_of_bvp = diff(o_data.of_bvp);

            % find peaks in 1st derivative that match with zero crossings of 1st derivative.
            [PKS{k},LOCS{k},~,P{k}] = findpeaks(100*o_data.diff_of_bvp);
            idx_pks = find(P{k}>0.1);

            %% 3 - Split Segments
            % Split the segments using the found peaks on first derivative.
            for n=1:length(LOCS{k}(idx_pks))-1
                s_seg{k,n}.t = data_in{k}.t(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.bvp = data_in{k}.bvp(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.sc = data_in{k}.sc(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.skt = data_in{k}.skt(LOCS{k}(idx_pks(n)):LOCS{k}(idx_pks(n+1)));
                s_seg{k,n}.pks = length(LOCS{k}(idx_pks));
            end

%             fprintf('Generated %i segments\n', n)
        end
end
end
