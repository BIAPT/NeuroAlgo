function [dpli_struct] = fp_dpli(eeg_data,eeg_info,parameters,mask)
%FP_DPLI Calculate frontoparietal dPLI measure (average dPLI for midline
%and lateral electrodes)
%   Input:
%       eeg_data: data to calculate the measures on
%       eeg_info: headset information
%       parameters: variables data as inputed by the user
%       midline_mask: boolean mask for the midline electrodes
%       lateral_mask: boolean mask for the lateral electrode
%   Output:
%       dpli is a struct containing the following:    
%       avg_dpli_left_midline: average dPLI for the left midline electrodes
%       avg_dpli_left_lateral: average dPLI for the left lateral electrodes
%       avg_dpli_right_midline: average dPLI for the right midline electrodes
%       avg_dpli_right_lateral: average dPLI for the right lateral electrodes

    %% Use the boolean mask to get relevant data
    left_midline_eeg = eeg_data(mask.left_midline_channels == 1,:);
    left_lateral_eeg = eeg_data(mask.left_lateral_channels == 1,:);
    right_midline_eeg = eeg_data(mask.right_midline_channels == 1,:);
    right_lateral_eeg = eeg_data(mask.right_lateral_channels == 1,:);
    
    %% Calculate the dPLI
    left_midline_dpli = dpli(left_midline_eeg,eeg_info,parameters);
    left_lateral_dpli = dpli(left_lateral_eeg,eeg_info,parameters);
    right_midline_dpli = dpli(right_midline_eeg,eeg_info,parameters);
    right_lateral_dpli = dpli(right_lateral_eeg,eeg_info,parameters);

    %% Calculate the average for the midline and lateral electrodes
    dpli_struct = struct();
    dpli_struct.left_midline = mean2(left_midline_dpli);
    dpli_struct.left_lateral = mean2(left_lateral_dpli);
    dpli_struct.right_midline = mean2(right_midline_dpli);
    dpli_struct.right_lateral = mean2(right_lateral_dpli);
end

