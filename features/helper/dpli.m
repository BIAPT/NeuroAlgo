function [corrected_dpli] = dpli(eeg_data,eeg_info,parameters)
%DPLI calculate weighted PLI and do some correction
%   Input:
%       eeg_data: data to calculate pli on
%       eeg_info: info about the headset
%       parameters: variable data as inputed by the user
%   Output:
%       corrected_wpli: PLI with a correction (either p value or
%       substraction)

    %% Seting up variables
    number_surrogates = parameters.number_surrogates;
    number_channels = size(eeg_data,1);
    surrogates_dpli = zeros(number_surrogates,number_channels,number_channels);
    eeg_data = eeg_data';
    
    %% Calculate dPLI
    uncorrected_dpli = d_PhaseLagIndex(eeg_data); % uncorrected
    uncorrected_dpli(isnan(uncorrected_dpli)) = 0.5; %Have to do this otherwise NaN break the code
    
    %% Generate Surrogates
    for index = 1:number_surrogates
        surrogates_dpli(index,:,:) = d_PhaseLagIndex_surrogate(eeg_data);
    end
    
    %% Correct the dPLI
    corrected_dpli = get_corrected_dpli(uncorrected_dpli,surrogates_dpli,parameters);

end

% this function correct the dPLI either by doing a substraction or
% significance testing
function [corrected_dpli] = get_corrected_dpli(uncorrected_dpli,surrogates_dpli,parameters)
    is_surrogates = parameters.is_surrogates;
    if(is_surrogates)
        p_value = parameters.p_value;
        corrected_dpli = zeros(size(uncorrected_dpli));
            %Here we compare the calculated dPLI versus the surrogate
            %and test for significance
            
            %if the result is significant then 4 conditions are possible
            %1.dPLI value is greater than 0.5 and the median of the surrogate
            %is greater than 0.5
            %2.dPLI value is smaller than 0.5 and the median of the surrogate
            %is smaller than 0.5
            %3.dPLI is greater than 0.5 and median of surrogate is smaller
            %than 0.5
            %4.dPLI is smaller than 0.5 and median of surrogate is greater
            %than 0.5
            for m = 1:length(uncorrected_dpli)
                for n = 1:length(uncorrected_dpli)
                    test = surrogates_dpli(:,m,n);
                    p = signrank(test, uncorrected_dpli(m,n)); 
                    disp(p);
                    if p < p_value % 4 Conditions 
                        if uncorrected_dpli(m,n) > 0.5 && median(test) > 0.5
                            gap = uncorrected_dpli(m,n) - median(test);
                                if(gap < 0)
                                    corrected_dpli(m,n) = 0.5; 
                                else
                                    corrected_dpli(m,n) = gap + 0.5; %Gap is positive here
                                end  
                        elseif uncorrected_dpli(m,n) < 0.5 && median(test) < 0.5 % CASE 2
                            gap = uncorrected_dpli(m,n) - median(test);
                            if(gap > 0)
                                corrected_dpli(m,n) = 0.5; 
                            else
                                corrected_dpli(m,n) = gap + 0.5; %Gap is negative here
                            end
                        elseif uncorrected_dpli(m,n) > 0.5 && median(test) < 0.5 %CASE 3
                            extra = 0.5 - median(test);
                            corrected_dpli(m,n) = uncorrected_dpli(m,n) + extra;
                        elseif uncorrected_dpli(m,n) < 0.5 && median(test) > 0.5 %CASE 4
                            extra = median(test) - 0.5;
                            corrected_dpli(m,n) = uncorrected_dpli(m,n) - extra;
                        end
                    else
                        corrected_dpli(m,n) = 0.5;
                    end
                end
            end
    else
        % Here we simply substract the surrogates dPLI from the uncorrected
        % dPLi
        corrected_dpli = uncorrected_dpli - squeeze(mean(surrogates_dpli,1));
        corrected_dpli(corrected_dpli<0) = 0;
    end

end
