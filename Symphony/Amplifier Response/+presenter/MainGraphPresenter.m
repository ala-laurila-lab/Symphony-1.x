classdef MainGraphPresenter < Presenter
    
    properties(Access = private)
        graphingService
        averageResponsePresenter;
        psthResponsePresenter;
    end
    
    methods(Access = protected)
        
        function onGoing(obj)
            v = obj.view;
            v.setControlsLayout(obj.graphingService.channels);
        end
        
        function onBind(obj)
            v = obj.view;
            addlistener(v, 'UpdateSelectedAmplifiers', @obj.updateAmplifiers);
            addlistener(v, 'StartSpikeDetection', @obj.startSpikeDetection);
            addlistener(v, 'StopSpikeDetection', @obj.stopSpikeDetection);
            addlistener(v, 'SetThreshold', @obj.setThreshold);
            addlistener(v, 'ShowPsthResponse', @obj.showPSTHResponse);
            addlistener(v, 'ShowAvgResponse', @obj.showAverageResponse);
        end
    end
    
    methods
        
        function obj = MainGraphPresenter(service, view)
            obj@Presenter(view);
            obj.graphingService = service;
        end
        
        function updateAmplifiers(obj, ~, eventData)
            channel = eventData.key;
            obj.graphingService.set(channel, 'active', eventData.value);
        end
        
        function setThreshold(obj, ~, ~)
            s = obj.graphingService;
            threshold = obj.view.getSpikeThreshold();
            channels = s.getActiveChannels();
            cellfun(@(ch) s.setThreshold(ch, threshold), channels);
        end
        
        function startSpikeDetection(obj, ~, ~)
            s = obj.graphingService;
            obj.setThreshold();
            channels = s.getActiveChannels();
            cellfun(@(ch) s.setSpikeDetector(ch, 1), channels);
        end
        
        function stopSpikeDetection(obj, ~, ~)
            s = obj.graphingService;
            channels = s.getActiveChannels;
            cellfun(@(ch) m.setSpikeDetector(ch, 0), channels);
        end
        
        function plotGraph(obj, epoch)
            s = obj.graphingService;
            if s.isProtocolChanged(epoch)
                s.reset(epoch);
                %TODO alert user for change of protocol
                obj.closeAverageResponsePresenter();
                obj.closePSTHResponsePresenter();
            end
            v = obj.view;
            chs = s.getActiveChannels();
            
            for i = 1:length(chs)
                [x, y, props] = s.getReponse(chs{i}, epoch);
                v.plot(x, y, 'color', props('color'));
                [x1, y1, threshold] = s.getSpike(chs{i}, epoch);
                s.computeAverage(chs{i}, epoch);
                v.refline(x, threshold);
                v.plotSpike(x1, y1, props);
                
            end
            v.resetGraph();
            v.renderGraph();
            obj.showAverageResponse();
            obj.showPSTHResponse();
        end
        
        function closeAverageResponsePresenter(obj)
            if ~isempty(obj.averageResponsePresenter)
                obj.averageResponsePresenter.stop();
                obj.averageResponsePresenter= [];
            end
        end
        
        function closePSTHResponsePresenter(obj)
            if ~isempty(obj.psthResponsePresenter)
                obj.psthResponsePresenter.stop();
                obj.psthResponsePresenter= [];
            end
        end
        
        
        function showAverageResponse(obj, ~, ~)
            ischecked = obj.view.hasAvgResponseChecked();
            if ischecked && isempty(obj.averageResponsePresenter)
                v = view.AverageResponseView();
                spikeService = obj.graphingService.getSpikeStatisticsMap();
                obj.averageResponsePresenter = presenter.AverageResponsePresenter(v, spikeService);
                obj.averageResponsePresenter.go();
            end
            if ischecked
                obj.averageResponsePresenter.viewAverageResponse();
            end
        end
        
        function showPSTHResponse(obj, ~, ~)
            ischecked = obj.view.hasPSTHResponseChecked();
            if ischecked && isempty(obj.psthResponsePresenter)
                v = view.PsthResponseView();
                spikeService = obj.graphingService.getSpikeStatisticsMap();
                obj.psthResponsePresenter = presenter.PsthResponsePresenter(v, spikeService);
                obj.psthResponsePresenter.go();
            end
            if ischecked
                obj.psthResponsePresenter.viewPsthResponse();
            end
        end
    end
end

