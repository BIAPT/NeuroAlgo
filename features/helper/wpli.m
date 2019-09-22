function [corrected_wpli] = wpli(eeg_data, number_surrogates, p_value)
%WPLI calculate weighted PLI and do some correction
%   Input:
%       eeg_data: data to calculate pli on
%       eeg_info: info about the headset
%       parameters: variable data as inputed by the user
%   Output:
%       corrected_wpli: PLI with a correction (either p value or
%       substraction)

%% Seting up variables
    number_channels = size(eeg_data,1);
    surrogates_wpli = zeros(number_surrogates,number_channels,number_channels);
    eeg_data = eeg_data';
    
    %% Calculate wPLI
    uncorrected_wpli = w_PhaseLagIndex(eeg_data); % uncorrected
    uncorrected_wpli(isnan(uncorrected_wpli)) = 0; %Have to do this otherwise NaN break the code
    
    %% Generate Surrogates
    for index = 1:number_surrogates
        surrogates_wpli(index,:,:) = w_PhaseLagIndex_surrogate(eeg_data);
    end
    
    %% Correct the wPLI (either by substracting or doing a p test)
    %Here we compare the calculated dPLI versus the surrogate
    %and test for significance
    corrected_wpli = zeros(size(uncorrected_wpli));
    for m = 1:length(uncorrected_wpli)
        for n = 1:length(uncorrected_wpli)
            test = surrogates_wpli(:,m,n);
            p = signrank(test, uncorrected_wpli(m,n));       
            if p < p_value
                if uncorrected_wpli(m,n) - median(test) > 0 %Special case to make sure no PLI is below 0
                    corrected_wpli(m,n) = uncorrected_wpli(m,n) - median(test);
                end
            end          
        end
    end
end

function WPLI=w_PhaseLagIndex(bdata)
    % INPUT:
    %   bdata: band-pass filtered data

    ch=size(bdata,2); % column should be channel
    a_sig=hilbert(bdata);
    WPLI=ones(ch,ch);

    for c1=1:ch-1
        for c2=c1+1:ch
            c_sig=a_sig(:,c1).*conj(a_sig(:,c2));

            numer=abs(mean(imag(c_sig))); % average of imaginary
            denom=mean(abs(imag(c_sig))); % average of abs of imaginary

            WPLI(c1,c2)=numer/denom;
            WPLI(c2,c1)=WPLI(c1,c2);
        end
    end 
end

function surro_WPLI=PhaseLagIndex_surrogate(X)
    % Given a multivariate data, returns phase lag index matrix
    % Modified the mfile of 'phase synchronization'
    ch=size(X,2); % column should be channel
    splice = randi(length(X));  % determines random place in signal where it will be spliced

    a_sig=hilbert(X);
    a_sig2= [a_sig(splice:length(a_sig),:); a_sig(1:splice-1,:)];  % %This is the randomized signal
    surro_WPLI=ones(ch,ch);

    for c1=1:ch-1
        for c2=c1+1:ch
            c_sig=a_sig(:,c1).*conj(a_sig2(:,c2));

            numer=abs(mean(imag(c_sig))); % average of imaginary
            denom=mean(abs(imag(c_sig))); % average of abs of imaginary

            surro_WPLI(c1,c2)=numer/denom;
            surro_WPLI(c2,c1)=surro_WPLI(c1,c2);
        end
    end 
end