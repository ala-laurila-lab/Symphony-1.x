classdef AmpRespPresenter < handle
    %AMPRESPCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ampRespView
        ampRespModel
        listeners
        plotRepo
        genericTO;
        app;
    end
    
    properties(Constant)
        SPIKE_STATS_FOLDER = 'Plots';
    end
    
    methods
        
        function obj = AmpRespPresenter(model, view)
            obj.ampRespModel = model;
            obj.ampRespView = view;
            obj.plotRepo = util.PlotRepository(obj.SPIKE_STATS_FOLDER);
        end
        
        function init(obj)
            v = obj.ampRespView;
            addlistener(v, 'updateAmplifiers', @obj.updateAmplifiers);
            addlistener(v, 'startSpikeDetection', @obj.startSpikeDetection);
            addlistener(v, 'stopSpikeDetection', @obj.stopSpikeDetection);
            addlistener(v, 'setThreshold', @obj.setThreshold);
            obj.genericTO = transferObject.GenericTO;
            obj.genericTO.persistant.spd = obj.ampRespModel.getSpikeDetectorContainer;
            obj.plotRepo.addlistener(v, 'plotSpikeStats');
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
                m.reset;
            end
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
            obj.genericTO.transient.epoch = epoch;
            notify(v, 'plotSpikeStats', util.EventData('obj', obj.genericTO));
        end
        
        function destroy(obj)
            %TODO destroy all listeneres and figures
        end
    end
end

