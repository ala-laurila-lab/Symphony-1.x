classdef AmpRespPresenter < handle
    %AMPRESPCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ampRespView
        psthRespView
        
        ampRespModel
        listeners
    end
    
    methods
        
        function obj = AmpRespPresenter(m, v)
            obj.ampRespModel = m;
            obj.ampRespView = v;
            %MVPQ Is nested view allowed in mvp pattern
            obj.psthRespView = view.PsthRespView;
        end
        
        function init(obj)
            v = obj.ampRespView;
            addlistener(v, 'updateAmplifiers', @obj.updateAmplifiers);
            addlistener(v, 'startSpikeDetection', @obj.startSpikeDetection);
            addlistener(v, 'stopSpikeDetection', @obj.stopSpikeDetection);
            addlistener(v, 'setThreshold', @obj.setThreshold);
            addlistener(v, 'psthResponse', @obj.showPSTHResponse);
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
            if m.isProtocolChanged(epoch)
                m.reset(epoch);
                %TODO alert user for change of psth response
                obj.showPSTHResponse;
            end
            v = obj.ampRespView;
            chs = m.getActiveChannels;
            
            for i = 1:length(chs)
                [x, y, props] = m.getReponse(chs{i}, epoch);
                v.plotEpoch(x, y, props);
                [x1, y1, threshold] = m.getSpike(chs{i}, epoch);
                v.refline(x, threshold);
                v.plotSpike(x1, y1, props);
                notify(obj.psthRespView, 'psthResponse', util.EventData('channel', chs{i}));
            end
            v.resetGraph;
            v.renderGraph;
        end
        
        function showPSTHResponse(obj, ~, ~)
            v = obj.ampRespView;
            status = get(v.psthResponseChkBox, 'Value');
            app = obj.ampRespModel.getSpikeStatisticsMap;
            %TODO alert user if status is active and app is empty
            if ~isempty(app)
                v = obj.psthRespView;
                m = model.PsthRespModel;
                p = presenter.PsthRespPresenter(v, m, app);
                p.show(status);
            end
        end
        
        function destroy(obj)
            %TODO destroy all listeneres and figures
        end
    end
end

