classdef SinglePhotonResponseStatistics < service.ResponseStatistics
    
    properties (Access = private)
        photonRate
    end
    
    methods
        
        function obj = SinglePhotonResponseStatistics(amplifier)
            obj = obj@service.ResponseStatistics(amplifier);
        end
        
        function init(obj, epoch)
            init@service.ResponseStatistics(obj, epoch);
            obj.avgResponse = cell(1, 1);
            obj.photonRate = epoch.parameters.photonRate;
        end
        
        function intensities = getGroupByLabel(obj)
            intensities = obj.photonRate;
        end
        
        function groupIndices = getGroupIndices(obj, id)
            groupIndices = obj.startEpochId :  obj.endEpochId;
        end
        
        function index = getCurrentGroupIndex(obj, id)
            index = 1;
        end
    end
end