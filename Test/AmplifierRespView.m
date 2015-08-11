classdef AmplifierRespView  < handle
    %AMPLIFIERRESPONSEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        amplifierRespGraphView
        amplifierRespControlView
        amplifierRespController
        amplifierRespModel
    end
    
    properties(Access = private)
        figureHandle
        infoLayout
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
            
            obj.amplifierRespModel = model.AmplifierRespModel;
            rigConfig = RigConfig;
            obj.amplifierRespController = controller.AmplifierRespController(rigConfig);
            obj.amplifierRespController.init(obj.amplifierRespModel);
            obj.createView();
            
        end
        
        function createView(obj)
            layout = uiextras.VBox(...
                'Parent', obj.figureHandle);
            obj.infoLayout = uiextras.HBox('Parent',layout);
            obj.amplifierRespGraphView = view.AmplifierRespGraphView(obj.amplifierRespModel, obj.amplifierRespController, layout);
            obj.amplifierRespControlView = view.AmplifierRespControlView(obj.amplifierRespModel, obj.amplifierRespController, layout);
            set(layout, 'Sizes', [-0.5 -5 120]);
        end
        
        function plot(obj,epoch)
            graphView = obj.amplifierRespGraphView;
            graphView.plotGraph(epoch);
        end
    end
    
end

