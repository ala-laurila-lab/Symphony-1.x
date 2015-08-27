classdef AmpRespPresenter < handle
    %AMPRESPCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ampRespView
        ampRespModel
        listeners
    end
    
    methods
        
        function obj = AmpRespPresenter(model, view)
            obj.ampRespModel = model;
            obj.ampRespView = view;
        end
        
        function init(obj)
            v = obj.ampRespView;
            addlistener(v, 'updateAmplifiers', @obj.updateAmplifiers);
            addlistener(v, 'startSpikeDetection', @obj.runSpikeDetector);
            addlistener(v, 'stopSpikeDetection', @obj.runSpikeDetector);
            addlistener(v, 'setThreshold', @obj.setThreshold);
        end
        
        function updateAmplifiers(obj, ~, eventData)
            ch = eventData.key;
            obj.ampRespModel.set(ch, 'active', eventData.value);
        end
        
        function setThreshold(obj, ~, ~)
            obj.ampRespModel.setThreshold(obj.ampRespView.thresholdTxt);
        end
        
        function runSpikeDetector(obj, ~, ~)
            obj.ampRespModel.setSpikeDetector(state);
        end
        
        function show(obj, channels)
             v = obj.ampRespView;
             v.render(channels);
        end
        
        function plotGraph(obj, epoch)
            m = obj.ampRespModel;
            chs = m.getActiveChannels;
            for i = 1:length(chs)
                [x, y, props] = m.getReponse(chs{i}, epoch);
                v.plotEpoch(x, y, props);
                [x, y] = m.getSpike(chs{i}, epoch);
                v.plotSpike(x, y, props);
            end
        end
        
        function destroy(obj)
            %TODO destroy all listeneres and figures
        end
    end
end

