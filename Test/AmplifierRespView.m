classdef AmplifierRespView  < handle
    %AMPLIFIERRESPONSEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model
    end
    
    properties(Access = private)
        figureHandle
        infoLayout
        graphView
        controlView
        controller
    end
    
    events
        plotSpikeStats
    end
    
    methods
        
        function obj = AmplifierRespView()
            obj.figureHandle = figure( ...
                'Name', 'Graphical Amplifier Response', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off' );
            set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            
            obj.model = model.AmplifierRespModel;
            rigConfig = RigConfig;
            obj.controller = controller.AmplifierRespController(rigConfig);
            obj.controller.init(obj.model);
            obj.controller.addListener(obj, 'plotSpikeStats')
            obj.createView();
            
        end
        
        function createView(obj)
            layout = uiextras.VBox(...
                'Parent', obj.figureHandle);
            obj.infoLayout = uiextras.HBox('Parent',layout);
            obj.graphView = view.AmplifierRespGraphView(obj.model, obj.controller, layout);
            obj.controlView = view.AmplifierRespControlView(obj.model, obj.controller, layout);
            set(layout, 'Sizes', [-0.5 -5 120]);
        end
        
        function plot(obj,epoch)
            obj.graphView.plotGraph(epoch);
            spd = obj.model.spikeDetectorMap;
            notify(obj, 'plotSpikeStats');
        end
    end
    
end

