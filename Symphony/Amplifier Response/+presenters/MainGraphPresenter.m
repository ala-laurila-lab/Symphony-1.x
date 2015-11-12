classdef MainGraphPresenter < Presenter
    
    properties(Access = private)
        graphingService
        averageResponsePresenter
        psthResponsePresenter
    end
    
    methods(Access = protected)
        
        function onGoing(obj)
            v = obj.view;
            v.setControlsLayout(obj.graphingService.channels);
            v.setInfoLayout();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'UpdateSelectedAmplifiers', @obj.updateAmplifiers);
            obj.addListener(v, 'StartSpikeDetection', @obj.startSpikeDetection);
            obj.addListener(v, 'StopSpikeDetection', @obj.stopSpikeDetection);
            obj.addListener(v, 'SetThreshold', @obj.setThreshold);
            obj.addListener(v, 'ShowPsthResponse', @obj.showPSTHResponse);
            obj.addListener(v, 'ShowAvgResponse', @obj.showAverageResponse);
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
            v = obj.view;
            idx = v.getSelectedChannelIdx();
            tf = ~ isempty(idx);
            v.viewAverageResponseCheckBox(tf);
            v.viewPSTHResponseCheckBox(tf);
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
            v.viewEpochSummary(s.protocol.numEpochsCompleted, s.protocol.numberOfEpochs);
            v.viewProtocolSummary(s.protocol.tostr());
            v.viewDeviceSummary(s.getDeviceInfo(epoch));
            
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
        
        function closeAverageResponsePresenter(obj, ~, ~)
            presenter = obj.averageResponsePresenter;
            if ~isempty(presenter)
                if ~ presenter.isStopped()
                    presenter.stop();
                end
                obj.averageResponsePresenter = [];
            end
        end
        
        function closePSTHResponsePresenter(obj, ~, ~)
            if ~isempty(obj.psthResponsePresenter)
                if ~ obj.isStopped
                    obj.psthResponsePresenter.stop();
                end
                obj.psthResponsePresenter = [];
            end
        end
        
        function showAverageResponse(obj, ~, ~)
            service = obj.graphingService;
            if ~obj.view.hasAvgResponseChecked() || ~service.isStarted()
                return;
            end
            
            presenter = obj.averageResponsePresenter;
            if isempty(presenter)
                spikeService = service.getSpikeStatisticsMap();
                presenter = presenters.AverageResponsePresenter(spikeService);
                addlistener(presenter, 'Stopped', @(h,d) obj.setAverageResponsePresenter([]));
                presenter.go();
                obj.averageResponsePresenter = presenter;
            end
            presenter.viewAverageResponse();
        end
        
        function showPSTHResponse(obj, ~, ~)
            service = obj.graphingService;
            if ~obj.view.hasPSTHResponseChecked() || ~service.isStarted()
                return;
            end
            
            presenter = obj.psthResponsePresenter;
            if isempty(obj.psthResponsePresenter)
                spikeService = obj.graphingService.getSpikeStatisticsMap();
                presenter = presenters.PsthResponsePresenter(spikeService);
                addlistener(presenter, 'Stopped', @(h,d) obj.setPsthResponsePresenter([]));
                presenter.go();
                obj.psthResponsePresenter = presenter;
            end
            presenter.viewPsthResponse();
        end
        
        function setPsthResponsePresenter(obj, p)
            obj.psthResponsePresenter = p;
        end
        
        function setAverageResponsePresenter(obj, p)
            obj.averageResponsePresenter = p;
        end
    end
end

