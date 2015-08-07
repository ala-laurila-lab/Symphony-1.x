classdef RigConfig < handle
    %RIGCONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = RigConfig()
        end

    	function channels = multiClampDeviceNames(obj)
    		channels = {'ch1', 'ch2', 'ch3', 'ch4'};
    	end
    end
    
end

