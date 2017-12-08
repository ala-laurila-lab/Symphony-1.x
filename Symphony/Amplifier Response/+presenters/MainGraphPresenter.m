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
            obj.addListener(v, 'UpdateSelectedAmplifiers', @obj.updateSelectedChannels);
            obj.addListener(v, 'StartSpikeDetection', @obj.startSpikeDetection);
            obj.addListener(v, 'StopSpikeDetection', @obj.stopSpikeDetection);
            obj.addListener(v, 'SetThreshold', @obj.setThreshold);
            obj.addListener(v, 'ShowPsthResponse', @obj.showPSTHResponse);
            obj.addListener(v, 'ShowAvgResponse', @obj.showAverageResponse);
        end
        
        function onGo(obj)
            obj.updateSelectedChannels();
            obj.updateOtherPlots();
            obj.startSpikeDetection();
        end 
    end
    
    methods
        
        function obj = MainGraphPresenter(service, view)
            obj@Presenter(view);
            obj.graphingService = service;
        end
        
        function updateSelectedChannels(obj, ~, ~)
            v = obj.view;
            idx = v.getSelectedChannelIdx();
            obj.graphingService.updateChannels(idx);
        end
        
        function updateOtherPlots(obj)
            idx = v.getSelectedChannelIdx();
            tf = ~ isempty(idx);
            v.viewAverageResponseCheckBox(tf);
            v.viewPSTHResponseCheckBox(tf);
        end
        
        % set threshold for all channels 
        % TODO - Can be individualized for channels  
        function setThreshold(obj, ~, ~)
            threshold = obj.view.getSpikeThreshold();
            obj.graphingService.setThreshold(threshold);
        end
        
        function startSpikeDetection(obj, ~, ~)
            obj.setThreshold();
            obj.graphingService.setSpikeDetector(true);
            obj.view.viewSpikeEnableButton(false);
            obj.view.viewSpikeDisableButton(true);
        end
        
        function stopSpikeDetection(obj, ~, ~)
            obj.graphingService.setSpikeDetector(false);
            obj.view.viewSpikeEnableButton(true);
            obj.view.viewSpikeDisableButton(false);
        end
        
        function plotGraph(obj, epoch)
            s = obj.graphingService;

            if s.hasProtocolChanged()
                s.reset(epoch);
                obj.closeAverageResponsePresenter();
                obj.closePSTHResponsePresenter();
                obj.updateSelectedChannels();
                obj.startSpikeDetection();
            end
            
            v = obj.view;
            v.setTitleText(s.protocol.numEpochsCompleted, s.protocol.numberOfEpochs, s.protocol.tostr(), s.getDeviceInfo(epoch));
            
            chs = s.activeChannels;
            for i = 1:length(chs)
                [x, y, props] = s.getCurrentEpoch(chs{i}, epoch);
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
                statisticsService = service.getResponseStatisticsMap();
                presenter = presenters.AverageResponsePresenter(statisticsService);
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
                statisticsService = obj.graphingService.getResponseStatisticsMap();
                presenter = presenters.PsthResponsePresenter(statisticsService);
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

