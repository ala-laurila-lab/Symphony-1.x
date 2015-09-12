classdef AmpRespModel < handle
    %AMPRESPMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channels
        serviceContext
        epochId = 0
        lastProtocol
        %TODO Refactor following constants to enum if posssible
        plotKeys = {'active', 'color', 'shift', 'scale', 'style'}
        colorSet = {'r', 'g', 'y', 'w', 'b', 'c'};
        parameterSchema = {...,
            'initialPulseAmplitude',...
            'scalingFactor',...
            'preTime',...
            'stimTime',...
            'tailTime',...
            'numberOfIntensities',...
            'numberOfRepeats',...
            'interpulseInterval',...
            'ampHoldSignal',...
            'backgroundAmplitude'};
        
    end
    
    methods
        
        function obj = AmpRespModel(channels)
            obj.serviceContext = struct();
            obj.channels = channels;
            
            for i = 1:length(channels)
                ch = channels{i};
                values = {false, obj.colorSet{i}, 0, 1, 'b*'};
                obj.serviceContext.(ch).props = containers.Map(obj.plotKeys, values);
                obj.serviceContext.(ch).statistics = service.SpikeStatistics(ch);
            end
        end
        
        function [x, y, props] = getReponse(obj, channel, epoch)
            [r, s, ~] = epoch.response(channel);
            x = (1:numel(r))/s;
            y = obj.changeOffSet(r, channel);
            props = obj.serviceContext.(channel).props;
        end
        
        function [x, y, threshold] = getSpike(obj, channel, epoch)
            x = []; y = [];
            spd = obj.serviceContext.(channel).statistics;
            threshold = spd.threshold;
            if spd.enabled
                [x ,y] = getReponse(obj, channel, epoch);
                [indices, s] = spd.detect(epoch, obj.epochId);
                x = indices/s;
                y = y(indices);
            end
        end
        
        function x = changeOffSet(obj, x, ch)
            scale = obj.serviceContext.(ch).props('scale');
            shift = obj.serviceContext.(ch).props('shift');
            x = x * scale + shift;
        end
        
        function set(obj, channel, key, value)
            obj.serviceContext.(channel).props(key) = value;
        end
        
        function activeChannels = getActiveChannels(obj)
            activeChannels = {};
            chs = obj.channels;
            idx = 1;
            
            for i =1:length(chs)
                if obj.serviceContext.(chs{i}).props('active') == 1
                    activeChannels{idx} = chs{i};
                    idx = idx + 1;
                end
            end
        end
        
        function setThreshold(obj, channel, thresholdTxt)
            spd = obj.serviceContext.(channel).statistics;
            spd.threshold = thresholdTxt;
        end
        
        function setSpikeDetector(obj, channel, state)
            spd = obj.serviceContext.(channel).statistics;
            spd.enabled = state;
        end
        
        function map = getSpikeStatisticsMap(obj)
            chs = obj.channels;
            s = cell(1,length(chs));
            for i = 1:length(chs)
                s{i} = obj.serviceContext.(chs{i}).statistics;
            end
            map = containers.Map(chs, s);
        end
        
        %TODO refactor this piece code for better understanding and
        %simplicity
        function changed = isProtocolChanged(obj, epoch)
            obj.epochId = obj.epochId + 1;
            schema = obj.parameterSchema;
            notChanged = true;
            
            if isempty(obj.lastProtocol)
                obj.lastProtocol = epoch.parameters;
            else
                old = obj.lastProtocol;
                new = epoch.parameters;
                for i = 1:length(schema)
                    notChanged = isequal( old.(schema{i}), new.(schema{i}) ) && notChanged;
                end
            end
            changed = ~ notChanged;
        end
        
        function reset(obj, epoch)
            obj.epochId = 0;
            obj.lastProtocol = [];
            cellfun(@(ch) obj.serviceContext.(ch).statistics.reset(epoch), obj.channels);
        end
    end
    
end

