classdef Signal
    %SIGNAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
         function Ind = getIndicesByThreshold(data, threshold, direction, varargin)
            %direction 1 = up, -1 = down
            if nargin > 3
                ubd = varargin{1};
            else
                ubd = Inf;
            end
            
            origData = data(1:end-1);
            shiftedData = data(2:end);
            
            if direction > 0
                ubd = abs(ubd);
                Ind = find(origData < threshold & shiftedData >= threshold & shiftedData < ubd) + 1;
            else
                ubd = -abs(ubd);
                Ind = find(origData >= threshold & shiftedData < threshold & shiftedData >= ubd) + 1;
            end
        end
    end
    
end

