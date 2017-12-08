classdef SinglePhotonResponseStatistics < ResponseStatistics
    
    properties (Access = private)
        photonRate
    end
    
    methods

        function init(obj, epoch)
            init@ResponseStatistics(obj, epoch);
            obj.avgResponse = cell(1, 1);
            obj.photonRate = epoch.photonRate
        end
        
        function intensities = getGroupByLabel(obj)
            intensities = obj.photonRate;
        end

        function groupIndices = getGroupIndices(obj, id)
            groupIndices = obj.startEpochId :  obj.endEpochId;
        end
        
        function index = getCurrentGroupIndex(obj, id)
            index = id;
        end
    end
end