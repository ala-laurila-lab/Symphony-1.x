classdef EpochTest < handle
    %EPOCHTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        noise
    end
    
    methods
        function obj = EpochTest
            obj.noise = randn(1,10000);
        end
        
        
        function [r, s, t] = response(obj, ch)
            if ch == 'ch1'
                r = obj.noise;
            elseif ch == 'ch2'
                r = 10 + obj.noise;
            elseif ch == 'ch3'
                r = 20 + obj.noise;
            elseif ch == 'ch4'
                r = 30 + obj.noise;
            end
            s = 10000;
            t = [];
        end
    end
    
end

