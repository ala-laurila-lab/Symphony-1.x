classdef AmpRespPresenter < handle
    %AMPRESPCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ampRespView
        ampRespModel
        listeners
    end
    
    methods
        
        function obj = AmpRespPresenter(model, view, app)
            obj.ampRespModel = model;
            obj.ampRespView = view;
        end
        
        function init(obj)
            v = obj.ampRespView;
            addlistener(v, 'updateAmplifiers', @obj.updateAmplifiers);
            addlistener(v, 'startSpikeDetection', @obj.startSpikeDetection);
            addlistener(v, 'stopSpikeDetection', @obj.stopSpikeDetection);
            addlistener(v, 'setThreshold', @obj.setThreshold);
        end
        
        function updateAmplifiers(obj, ~, eventData)
            ch = eventData.key;
            obj.ampRespModel.set(ch, 'active', eventData.value);
        end
        
        function setThreshold(obj, ~, ~)
            m = obj.ampRespModel;
            threshold = get(obj.ampRespView.thresholdTxt, 'String');
            chs = m.getActiveChannels;
            cellfun(@(ch) m.setThreshold(ch, str2double(threshold)), chs);
        end
        
        function startSpikeDetection(obj, ~, ~)
            m = obj.ampRespModel;
            obj.setThreshold;
            chs = m.getActiveChannels;
            cellfun(@(ch) m.setSpikeDetector(ch, 1), chs);
        end
        
        function stopSpikeDetection(obj, ~, ~)
            m = obj.ampRespModel;
            chs = m.getActiveChannels;
            cellfun(@(ch) m.setSpikeDetector(ch, 0), chs);
        end
        
        function show(obj)
            v = obj.ampRespView;
            channels = obj.ampRespModel.channels;
            v.render(channels);
        end
        
        function plotGraph(obj, epoch)
            m = obj.ampRespModel;
            v = obj.ampRespView;
            chs = m.getActiveChannels;
           
            for i = 1:length(chs)
                [x, y, props] = m.getReponse(chs{i}, epoch);
                v.plotEpoch(x, y, props);
                [x, y] = m.getSpike(chs{i}, epoch);
                v.plotSpike(x, y, props);
            end
            v.resetGraph;
            v.renderGraph;
        end
        
        function destroy(obj)
            %TODO destroy all listeneres and figures
        end
    end
end

