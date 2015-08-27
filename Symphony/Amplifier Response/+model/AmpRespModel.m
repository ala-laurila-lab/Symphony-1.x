classdef AmpRespModel < handle
    %AMPRESPMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channels
        plots
        plotKeys = {'active', 'color', 'shift', 'scale', 'style'}
        colorSet = {'r', 'g', 'y', 'w', 'b', 'c'};
        plotContainer
    end
    
    methods
        
        function obj = AmpRespModel(channels)
            obj.plots = struct();
            for i = 1:length(channels)
                values = {false, obj.colorSet{i}, 0, 1, 'b*'};
                obj.plots.(channels{i}).props = containes.Map(obj.plotKeys, values);
                obj.plots.(channels{i}).SpikeDetector = model.SpikeDetector;
            end
        end
        
        function [x, y, props] = getReponse(obj, channel, epoch)
            [r, s, ~] = epoch.response(channel);
            x = (1:numel(r))/s;
            y = obj.changeOffset(r);
            props = obj.plots.(ch).props;
        end
        
        function [x, y] = getSpike(obj, channel, epoch)
            x = []; y = [];
            
            spd = obj.plots.(channel).SpikeDetector;
            if spd.enabled
                [x ,y] = getReponse(obj, channel, epoch)
                indices = spd.detect(epoch);
                x = indices/s;
                y = y(indices);
            end
        end
        
        function x = changeOffSet(obj, x, ch)
            scale = obj.plots.(ch).props('scale');
            shift = obj.plots.(ch).props('shift');
            x = x * scale + shift;
        end
        
        function set(obj, channel, key, value)
            obj.plots.(channel).props(key) = value;
        end
        
        function activeChannels = getActiveChannels(obj)
            activeChannels = [];
            chs = obj.channels;
            for i =1:length(chs)
                if obj.plots.(chs{i}).props('active') == 1
                    activeChannels = [chs{i} ;activeChannels]
                end
            end
        end
    end
    
end

