function [side,region] = assign_side_region(x,y)
%ASSIGN_PLI_REGION Summary of this function goes here
%   Detailed explanation goes here
    
    epsilon = 0.0000001;

    % Midline:
    X = [7.96264703000000, -6.67669403200000];
    Y = [0,0];
    [coefficients] = polyfit(X, Y, 1);
    slope = coefficients(1);
    intercept = coefficients(2);
    
    if(y < epsilon && y > -epsilon)
       side = 'both';
       region = 'midline';
    elseif(y > 0)
        side = 'left';
        region = get_left_region(x,y);
    else
        side = 'right';
        region = get_right_region(x,y);
    end

end


% Helper functions to get either the left or right region
function region = get_left_region(x,y)
    X = [6.02115996400000, 0.284948655000000, -4.49482169800000];
    Y = [4.45938718700000, 5.47913021000000, 5.83124149800000];
    [coefficients] = polyfit(X, Y, 1);
    slope = coefficients(1);
    intercept = coefficients(2);
    
    % Check if we are part of the three points
    for i=1:length(X)
       if(x == X(i))
           region = 'both';
           return;
       end
    end
    
    %Check if we are lateral and midline
    y_threshold = slope*x + intercept;
    if(y > y_threshold)
       region = 'lateral'; 
    else
        region = 'midline';
    end
    
end

function region = get_right_region(x,y)
    X = [6.02115996400000, 0.284948655000000, -4.49482169800000];
    Y = [-4.45938718700000, -5.47913021000000, -5.83124149800000];
    [coefficients] = polyfit(X, Y, 1);
    slope = coefficients(1);
    intercept = coefficients(2);
    
    % Check if we are part of the three points
    for i=1:length(X)
       if(x == X(i))
           region = 'both';
           return;
       end
    end
    
    %Check if we are lateral and midline
    y_threshold = slope*x + intercept;
    if(y < y_threshold)
       region = 'lateral'; 
    else
        region = 'midline';
    end
end