classdef GraphingService < handle
    
    properties
        channels % Has all the amplifer channels
         % Service context is the dynamic structure for above channels  
         % Field (1) (channels{i}).props; Value(1) for main graph properties refer getMainGraphProperties@GraphingConstants
         % Filed (2) (channels{i}).statistics; Value(2) service.ResponseStatistics objcet for each channel 
        serviceContext
        protocol
        averageGraphHolder
    end
    
    properties(Access = private)
        epochId = 0
        lastProtocol
    end
    
    methods
        
        function obj = GraphingService(channels)
            import constants.*;
            
            obj.serviceContext = struct();
            obj.channels = channels;
            
            for i = 1:length(channels)
                ch = channels{i};
                obj.serviceContext.(ch).props = GraphingConstants.getMainGraphProperties(i);
                obj.serviceContext.(ch).statistics = service.ResponseStatistics(ch);
            end
        end
        
        function [x, y, props] = getReponse(obj, channel, epoch)
            stimStart = epoch.getParameter('preTime')*1E-3;
            
            [r, s, ~] = epoch.response(channel);
            m = mean(r);
            r = r - m;
            x = (1:numel(r))/s - stimStart;
            y = obj.changeOffSet(r, channel);
            props = obj.serviceContext.(channel).props;
        end
        
        function [x, y, threshold] = getSpike(obj, channel, epoch)
            x = []; y = [];
            stimStart = epoch.getParameter('preTime')*1E-3;
            
            s = obj.serviceContext.(channel).statistics;
            threshold = s.threshold;
            if s.enabled
                [~ ,y] = getReponse(obj, channel, epoch);
                [indices, rate] = s.detect(epoch, obj.epochId);
                x = indices/rate - stimStart;
                y = y(indices);
            end
        end
        
        function computeAverage(obj, channel, epoch)
            s = obj.serviceContext.(channel).statistics;
            s.computeAvgResponseForTrails(epoch, obj.epochId);
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
        
        function map = getResponseStatisticsMap(obj)
            chs = obj.getActiveChannels;
            n = length(chs);
            s = cell(1, n);
            map = [];
            
            for i = 1:n
                s{i} = obj.serviceContext.(chs{i}).statistics;
            end
            if n ~= 0
                map = containers.Map(chs, s);
            end
        end
        
        %TODO refactor this piece code for better understanding and
        %simplicity
        function changed = isProtocolChanged(obj, epoch)
            obj.epochId = obj.epochId + 1;
            schema = constants.GraphingConstants.LED_PROTOCOL_PARAMETERS.cell;
            notChanged = true;
            
            if isempty(obj.lastProtocol)
                obj.lastProtocol = epoch.parameters;
                cellfun(@(ch) obj.serviceContext.(ch).statistics.init(epoch), obj.channels);
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
            cellfun(@(ch) obj.serviceContext.(ch).statistics.init(epoch), obj.channels);
        end
        
        function tf = isStarted(obj)
            tf = obj.epochId > 0;
        end
        
        function str = getDeviceInfo(~, epoch)
            str = 'Temprature';
            if epoch.containsParameter('Temp')
                str = sprintf('%s = %g C', str, epoch.getParameter('Temp'));
            end
        end
    end
    
end

