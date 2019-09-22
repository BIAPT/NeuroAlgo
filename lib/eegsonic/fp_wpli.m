function [wpli_struct] = fp_wpli(eeg_data,eeg_info,parameters,mask)
%FP_WPLI Calculate frontoparietal dPLI measure (average dPLI for midline
%and lateral electrodes)
%   Input:
%       eeg_data: data to calculate the measures on
%       eeg_info: headset information
%       parameters: variables data as inputed by the user
%       midline_mask: boolean mask for the midline electrodes
%       lateral_mask: boolean mask for the lateral electrode
%   Output:
%       wpli is a structure containing the following
%       left_midline: average wPLI for the left midline electrodes
%       left_lateral: average wPLI for the left lateral electrodes
%       right_midline: average wPLI for the right midline electrodes
%       right_lateral: average wPLI for the right lateral electrodes

    %% Use the boolean mask to get relevant data
    left_midline_eeg = eeg_data(mask.left_midline_channels == 1,:);
    left_lateral_eeg = eeg_data(mask.left_midline_channels == 1,:);
    right_midline_eeg = eeg_data(mask.right_midline_channels == 1,:);
    right_lateral_eeg = eeg_data(mask.right_midline_channels == 1,:);
    
    %% Calculate the wPLI
    left_midline_wpli = wpli(left_midline_eeg,eeg_info,parameters);
    left_lateral_wpli = wpli(left_lateral_eeg,eeg_info,parameters);
    right_midline_wpli = wpli(right_midline_eeg,eeg_info,parameters);
    right_lateral_wpli = wpli(right_lateral_eeg,eeg_info,parameters);

    %% Calculate the average for the midline and lateral electrodes
    wpli_struct = struct();
    wpli_struct.left_midline = mean2(left_midline_wpli);
    wpli_struct.left_lateral = mean2(left_lateral_wpli);
    wpli_struct.right_midline = mean2(right_midline_wpli);
    wpli_struct.right_lateral = mean2(right_lateral_wpli);
end

