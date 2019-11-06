function [data_in, array] = sqi_skt(data_in)
    % Usage: skt_sqi = sqi_skt(data_in)

    % input: data_in : structure containing, time, bvp, sc and skt signals from TPS sensor.
    %                 
    % Output: data_in : Same structure as data_in, with an added bvp_skt
    %                       field. 
    %
    % Coded by: Pascal Fortin
    % Supervised by: Stefanie Blain-Moraes, Jeremy R. Cooperstock
    % McGill University, Montreal, Canada
    % 

    % Detailed description
    % SKT signal quality uses the following features
    %   1. Minimum SKT value from the sample to see if the finger was removed
    %   (sudden approximately 0)
    %   2. Max-min in SKT value to detect abnormally wide range of values
    %   3. Standard deviation of the values. 


    %% 1.0 - Detrending filter
    % Sampling frequency
    Fs = 15;
    % cut-off frequency
    Fc_hp = 0.5;
    % BVP Normalized cut-off frequency
    nFc_hp = Fc_hp/Fs;
    % 3rd order high-pass filter with nFc
    [hfb, hfa] = butter(3,nFc_hp, 'high'); 

    %% 1 - Compute SQI
    % Initialize an empty array to hold the sqi values
    array = [];

    % For each segment in data_in
    for n=1:length(data_in)
        % Set default skt_SQI to 1
        data_in{n}.skt_SQI = 1;

        % Compute Max-Min of skin temperature to make sure it does not vary
        % unreasonably
        temp_min = min(data_in{n}.skt);
        temp_maxmin = max(data_in{n}.skt)-min(data_in{n}.skt);

        % Filter Detrend skin temperature signal
        temp_sktsignal = filtfilt(hfb, hfa, data_in{n}.skt);
        temp_sktstd = std(temp_sktsignal);

    %%
        % Generate a first approximation of SC sqi
        % 2*pi was chosen arbitrarily. might have to be fine tuned. 
        data_in{n}.skt_SQI = data_in{n}.skt_SQI*exp(-2*temp_sktstd);

        % If during the measurement, the finger was removed (... or very cold fingers)
        if temp_min < 20
            data_in{n}.skt_SQI = 0.5*data_in{n}.skt_SQI;
        end

        % If there are abnormally high variations of temperature (considering
        % the duration)
        if max(diff(data_in{n}.skt)) > 2
            data_in{n}.skt_SQI = 0.3*data_in{n}.skt_SQI;
        end    
%         if std(data_in{n}.skt) < 0.001 
%             data_in{n}.skt_SQI = 0.2*data_in{n}.skt_SQI;
%         end   
    end
end