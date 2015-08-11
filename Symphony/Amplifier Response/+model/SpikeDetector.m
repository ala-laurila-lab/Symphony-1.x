classdef SpikeDetector < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold
        direction
        enabled = false
    end
    
    properties(Access = private)
          amplifier
    end
    
    
    properties(Constant)
        SPIKE_TIME = 'spikeTime'
    end
    
    
    methods
        function obj = SpikeDetector(amplifier)
            obj.threshold = 0;
            obj.direction = sign(0);
            obj.amplifier = amplifier;
        end
        
        function indices = detect(obj, epoch)
            if obj.isvalid
                [data, ~, ~] = epoch.response(obj.amplifier);
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

