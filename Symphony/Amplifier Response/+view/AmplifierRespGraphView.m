classdef AmplifierRespGraphView < handle
    %AMPLIFIERGRAPHVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controller
        graph
        model
    end
    
    methods
        
        function obj = AmplifierRespGraphView(model, controller, layout)
            obj.controller = controller;
            obj.model = model;
            graphPanel = uiextras.BoxPanel(...
                'Title', 'Amplifier Response',...
                'Parent', layout,...
                'BackgroundColor', 'black');
            obj.graph = axes(...
                'Parent', graphPanel, ...
                'ActivePositionProperty', 'OuterPosition');
            resetGraph(obj)
        end
        
        function resetGraph(obj)
            grid(obj.graph, 'on');
            axis(obj.graph,'tight');
            set(obj.graph, 'XColor', 'White');
            set(obj.graph, 'YColor', 'White');
            set(obj.graph, 'Color', 'black');
        end
        
        function plotGraph(obj)
            data = struct('plotName',[],'x',[],'y',[]);
            channels = obj.controller.getChannels;
            testData = randn(1,10000);
            plots = [];
            for i = 1:length(channels)
                data.plotName = channels{i};
                data.y = (10 * i) + testData;
                data.x = 1:10000;
                if obj.model.plotMap(data.plotName)
                    h = plot(obj.graph,data.x,data.y);
                    plots = [plots, h];
                    hold on;
                    obj.resetGraph
                end
            end
            drawnow
            %cellfun(@(p) set(p,'visible','on'),plots);
            hold(obj.graph, 'off');
        end
    end
end

