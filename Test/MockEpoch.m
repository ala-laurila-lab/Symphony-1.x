classdef MockEpoch < handle
    %EPOCHTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        index = 1
        parameters
    end
    
    methods
        function obj = MockEpoch
            temp = load('cellData.mat');
            obj.data = temp.c;
        end
        
        function [r, s, t] = response(obj, ch)
            [r, s, t] = obj.data.epochs(obj.index).getData;
        end
        
        function nextIndex(obj)
            obj.index = obj.index + 1;        
        end
        
        function p = get.parameters(obj)
            map = obj.data.epochs(obj.index).attributes;
            k = map.keys;
            p = struct();
            for i = 1:length(k)
                p.(k{i}) = map(k{i});
            end
        end
    end
end

