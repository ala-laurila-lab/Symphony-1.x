classdef SpikeDetector < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold
        direction
    end
    
    
    properties(Constant)
        SPIKE_TIME = 'spikeTime'
    end
    
    
    methods
        function obj = SpikeDetector()
        end
        
        function indices = detect(obj, amplifier, epoch)
            if obj.isvalid
                [data, ~, ~] = epoch.response(amplifier);
                indices = util.Signal.getIndicesByThreshold(data, obj.threshold, obj.direction);
            end
        end
    end
    
    methods(Access = private)
        
        function valid = isValid(obj)
            valid = ~isempty(obj.threshold) && ~isempty(obj.direction);
        end
    end   
end

