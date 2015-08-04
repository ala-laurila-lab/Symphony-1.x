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
        
        function plotGraph(obj, epoch)
            channels = obj.controller.getChannels;
            
            for i = 1:length(channels)
                if obj.model.plotMap(channels{i})
                    [x, y] = obj.model.getData(channels{i}, epoch)
                    h = plot(obj.graph,data.x,data.y);
                    plots = [plots, h];
                    hold on;
                    obj.resetGraph
                end
            end
            drawnow
            hold off;
        end
    end
end

