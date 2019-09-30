function [configuration] = get_configuration()
%GET_CONFIGURATION Summary of this function goes here
%   Detailed explanation goes here
    [filepath,name,ext] = fileparts(mfilename('fullpath'));
    configuration_path = strcat(filepath,'/configuration.txt');
    file_id = fopen(configuration_path);
    
    configuration.is_verbose = get_is_verbose(file_id);
    
    fclose(file_id);
end

function [is_verbose] = get_is_verbose(file_id)
    is_verbose = 0;
    line = fgetl(file_id);
    while(line ~= -1)
        line = strtrim(line);
        line_data = split(line,"=");
        
        if(length(line_data) > 1)
            identifier = strtrim(line_data(1));
            value = strtrim(line_data(2));
            if(strcmp(identifier,"is_verbose"))
                is_verbose = str2double(value{1});
                break;
            end
        end
        line = fgetl(file_id);
    end
    frewind(file_id);
end

