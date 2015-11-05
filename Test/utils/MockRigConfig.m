classdef MockRigConfig < handle
    %RIGCONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MockRigConfig()
        end

    	function channels = multiClampDeviceNames(obj)
    		channels = {'ch1', 'ch2'};
    	end
    end
    
end

