classdef LEDFactorPulseResponseStatistics < service.ResponseStatistics
    
    
    properties(Access = private)
        initialPulseAmplitude
        numberOfIntensities
        scalingFactor
    end
    
    methods
        
        function obj = LEDFactorPulseResponseStatistics(amplifier)
            obj = obj@service.ResponseStatistics(amplifier);
        end
        
        function init(obj, epoch)
            init@service.ResponseStatistics(obj, epoch);
            p = epoch.parameters;
            obj.initialPulseAmplitude = p.initialPulseAmplitude;
            obj.numberOfIntensities = p.numberOfIntensities;
            obj.scalingFactor = p.scalingFactor;
            obj.avgResponse = cell(obj.numberOfIntensities, 1);
        end
        
        function intensities = getGroupByLabel(obj)
            v = obj.initialPulseAmplitude;
            scale = obj.scalingFactor;
            exponent = (0 : obj.numberOfIntensities-1);
            intensities = arrayfun(@(n) round((scale^n)*v), exponent);
        end

        function groupIndices = getGroupIndices(obj, id)
            groupIndices = (id : obj.numberOfIntensities : obj.endEpochId);
            groupIndices = groupIndices(groupIndices >= obj.startEpochId);
        end
        
        function index = getCurrentGroupIndex(obj, id)
            index = mod(id, obj.numberOfIntensities);
            
            if index == 0
                index = obj.numberOfIntensities;
            end
        end
    end
end