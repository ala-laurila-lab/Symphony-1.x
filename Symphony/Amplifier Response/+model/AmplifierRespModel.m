classdef AmplifierRespModel < handle
    %AMPLIFIERRESPMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        plotMap
        autoScale = false
    end
    
    methods
        
        function obj = AmplifierRespModel()
        end

        function [x,y] = getData(obj, amplifier, epoch)
        	[r, s, ~] = epoch.response(amplifier);
        	x = (1:numel(r))/s;
            y = r;

        end

        function valueSet = initPlotMapValues(obj, length)
            valueSet = cell(1, length);
            colorSet = {'r', 'g', 'y', 'w', 'b', 'c'};
            for i = 1:length
                valueSet{i} = struct('active', false, 'color', colorSet{i});
            end
        end     
    end
end

