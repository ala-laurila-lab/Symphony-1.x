classdef AmplifierRespModel < handle
    %AMPLIFIERRESPMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        plotMap
        autoScale = false
        spikeDetectorMap
        isSpikeDetectionEnabled = false
        channels
    end

    methods
        
        function obj = AmplifierRespModel()
        end
        
        function [x, y, threshold, spike_x, spike_y] = getData(obj, amplifier, epoch)
            spike_x = [];
            spike_y = [];
            
            changeOffset = @(x) x * obj.plotMap(amplifier).scale + obj.plotMap(amplifier).shift;
            spikeDetector = obj.spikeDetectorMap(amplifier);
            [r, s, ~] = epoch.response(amplifier);
            x = (1:numel(r))/s;
            y = changeOffset(r);
            threshold =  changeOffset(spikeDetector.threshold);   

            if spikeDetector.enabled
                indices = spikeDetector.detect(epoch);
                spike_x = indices/s;
                spike_y = y(indices);
            end
        end
        
        function valueSet = init(obj, keys)
            valueSet = cell(1, length(keys));
            colorSet = {'r', 'g', 'y', 'w', 'b', 'c'};
            obj.spikeDetectorMap = containers.Map();
            
            for i = 1:length(keys)
                obj.spikeDetectorMap(keys{i}) = model.SpikeDetector(keys{i});
                valueSet{i} = struct(...
                    'active', false,...
                    'color', colorSet{i},...
                    'shift', 0,...
                    'scale', 1);
            end
        end
        
        function set(obj, channel, property, value)
            s= obj.plotMap(channel);
            s.(property) = value;
            obj.plotMap(channel) = s;
        end
    end
end

