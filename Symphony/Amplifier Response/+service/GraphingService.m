classdef GraphingService < handle
    
    properties
        channels        % Has all the amplifer channels
        serviceContext  % Dynamic structure for amplifier channel response @see constructuor
        protocol        % Lab protocol
    end
    
    properties(Access = private)
        cachedProtocol  % Last observerd protocol
    end
    
    properties(Dependent, SetAccess = private)
        activeChannels
    end
    
    methods
        
        % Initilize service context object
        % Service context is the dynamic structure for amplifier channels
        % {'amp1', 'amp2'.. etc}
        %
        % Example
        % -------
        % 1. serviceContext.channels{'amp1'}.props contains color, scale
        % and marker attributes of amplifier response plot
        %
        % 2. serviceContext.channels{'amp1'}.statistics; contains
        % service.ResponseStatistics of amp1
        
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
        
        function [x, y, props] = getCurrentEpoch(obj, channel, epoch)
            [y, s] = obj.getBaselinedResponse(channel, epoch);
            
            stimStart = epoch.getParameter('preTime')*1E-3;
            x = (1:numel(y))/s - stimStart;
            
            props = obj.serviceContext.(channel).props;
        end
        
        function [x, y, threshold] = getSpike(obj, channel, epoch)
            x = []; y = [];
            s = obj.serviceContext.(channel).statistics;
            threshold = s.threshold;
            
            if s.enabled
                [y, ~] = obj.getBaselinedResponse(channel, epoch);
                [indices, rate] = s.detect(epoch, obj.protocol.numEpochsCompleted);
                y = y(indices);
                
                stimStart = epoch.getParameter('preTime')*1E-3;
                x = indices/rate - stimStart;
            end
        end
        
        function computeAverage(obj, channel, epoch)
            s = obj.serviceContext.(channel).statistics;
            s.computeAvgResponseForTrails(epoch, obj.protocol.numEpochsCompleted);
        end
        
        
        function x = changeOffSet(obj, x, ch)
            scale = obj.serviceContext.(ch).props('scale');
            shift = obj.serviceContext.(ch).props('shift');
            x = x * scale + shift;
        end
        
        function activeChannels = get.activeChannels(obj)
            activeChannels = {};
            chs = obj.channels;
            idx = 1;
            
            for i =1:length(chs)
                if obj.serviceContext.(chs{i}).props('active') == 1
                    activeChannels{idx} = chs{i}; %#ok
                    idx = idx + 1;
                end
            end
        end
        
        function updateChannels(obj, activeIdx)
            activeChannels = obj.channels(activeIdx);
            inActiveChannels = obj.channels(~ activeIdx);
            arrayfun(@(ch) obj.set(ch{1}, 'active', 1), activeChannels)
            arrayfun(@(ch) obj.set(ch{1}, 'active', 0), inActiveChannels)
        end
        
        function setThreshold(obj, thresholdTxt)
            chs = obj.activeChannels;
            
            for i = 1:length(chs)
                responseStatistics = obj.serviceContext.(chs{i}).statistics;
                responseStatistics.threshold = thresholdTxt;
            end
        end
        
        function setSpikeDetector(obj, state)
            chs = obj.activeChannels;
            
            for i = 1:length(chs)
                responseStatistics = obj.serviceContext.(chs{i}).statistics;
                responseStatistics.enabled = state;
            end
        end
        
        function map = getResponseStatisticsMap(obj)
            chs = obj.activeChannels;
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
        
        function tf = hasProtocolChanged(obj)
            tf = obj.numEpochsCompleted == 1 || (~ isempty(obj.cachedProtocol) && obj.cachedProtocol == obj.protocol);
        end
        
        function reset(obj, epoch)
            obj.cachedProtocol = copy(obj.protocol);
            cellfun(@(ch) obj.serviceContext.(ch).statistics.init(epoch), obj.channels);
        end
        
        function tf = isStarted(obj)
            tf = obj.protocol.numEpochsCompleted > 0;
        end
        
        %TODO move this piece of code in device specific class
        function str = getDeviceInfo(~, epoch)
            str = 'Temp';
            if epoch.containsParameter('Temp')
                str = sprintf('%s = %g C', str, epoch.getParameter('Temp'));
            end
        end
    end
    
    methods(Access = private)
        
        function [y, s]= getBaselinedResponse(obj, channel, epoch)
            [r, s, ~] = epoch.response(channel);
            m = mean(r);
            r = r - m;
            y = obj.changeOffSet(r, channel);
        end
        
        function set(obj, channel, key, value)
            obj.serviceContext.(channel).props(key) = value;
        end
    end
end

