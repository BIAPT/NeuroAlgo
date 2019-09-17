function output=delay_reconstruction(data, delay_time, embedding_dimension)
% INPUT
% data: 2-d matrix (time by channel)
% delay_time: delay time
% embedding_dimension: embedding dimension
%
% OUTPUT: 3-d matrix (time by EMB vector by channel)
% output(1,:,1) = [data(1) data(1+L) data(1+2L) ... data(1+(m-1)L)]
%
% Heonsoo Lee 2011.11.17
% Yacine Mahdid 2018.12.31 (Refactored for readability)

    %% Initialize variables
    [length,number_channels]=size(data);
    output=zeros(length-delay_time*(embedding_dimension-1),embedding_dimension,number_channels);

    for current_channel=1:number_channels
        for current_dimension=1:embedding_dimension
            % Get the start and end times
            start_time = 1+(current_dimension-1)*delay_time;
            end_time = length-(embedding_dimension-current_dimension)*delay_time;
            % slice the data
            current_data = data(start_time:end_time, current_channel);
            % store it at the right place
            output(:, current_dimension, current_channel)= current_data;
        end
    end

