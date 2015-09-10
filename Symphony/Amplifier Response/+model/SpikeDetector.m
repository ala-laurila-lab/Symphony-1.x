classdef SpikeDetector < handle
    %SPIKEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold
        enabled = false
        indices
        epochParams
        lastEpochId
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
            obj.indices = containers.Map;
            obj.lastEpochId = 0;
        end
        
        function [indices, s] = detect(obj, epoch, id)
            if obj.isvalid
                [data, s, ~] = epoch.response(obj.amplifier);
                m = mean(data);
                data = data - m;
                threshold = obj.threshold - m;
                indices = util.Signal.getIndicesByThreshold(data, threshold, sign(threshold));
                obj.indices(num2str(id)) = indices;
                obj.lastEpochId = id;
            end
            %fprintf('intensity [%d] no of repeats [%d]', epoch.getParameter('numberOfIntensities'), epoch.getParameter('numberOfRepeats'));
        end
        
        function reset(obj, params)
            obj.indices = containers.Map;
            obj.epochParams = params;
        end
        
        function spikes = getSpikeIndicesByEpochId(obj, id)
            spikes = [];
            columns = (id : obj.epochParams.numberOfIntensities : obj.lastEpochId);
            
            for i = 1:length(columns)
                spikes = [spikes, obj.indices(num2str(columns(i)))'];
            end
        end
        
        function intensities = intensitiesToVoltages(obj)
            v = obj.epochParams.pulseAmplitude;
            scale = obj.epochParams.scalingFactor;
            exponent = (1 : obj.epochParams.numberOfIntensities);
            intensities = arrayfun(@(n) (scale^n)*v, exponent);
        end
    end
    
    methods(Access = private)
        
        function valid = isValid(obj)
            valid = ~isempty(obj.threshold);
        end
    end
end

