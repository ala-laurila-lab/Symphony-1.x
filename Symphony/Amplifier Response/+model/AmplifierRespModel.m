classdef AmplifierRespModel < handle
    %AMPLIFIERRESPMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        plotMap
        autoScale = false
        lastEpochInfo;
    end
    
    methods
        
        function obj = AmplifierRespModel()
        end

        function [x,y] = getData(obj, amplifier, epoch)
        	[r, s, ~] = epoch.response(amplifier);
        	x = (1:numel(r))/s;
            y = r;
        end     
    end
end

