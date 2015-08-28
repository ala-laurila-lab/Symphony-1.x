classdef SpikeDetector < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold
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
            obj.amplifier = amplifier;
        end
        
        function [indices, s] = detect(obj, epoch)
            if obj.isvalid
                [data, s, ~] = epoch.response(obj.amplifier);
                indices = util.Signal.getIndicesByThreshold(data, obj.threshold, sign(obj.threshold));
            end
            %fprintf('intensity [%d] no of repeats [%d]', epoch.getParameter('numberOfIntensities'), epoch.getParameter('numberOfRepeats'));
        end
    end
    
    methods(Access = private)
        
        function valid = isValid(obj)
            valid = ~isempty(obj.threshold);
        end
    end   
end

