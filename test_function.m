function [out] = test_function(Recording,varargin)
%TEST_FUNCTION Summary of this function goes here
%   Detailed explanation goes here

    % Default Variables
    defaultWindow = 'hopping';
    expectedWindows = {'hopping'};

    p = inputParser;
    addParameter(p,'window',defaultWindow,...
                  @(x) any(validatestring(x,expectedWindows)));
    parse(p,varargin{:});
   
    out = p.Results.window; 

end

