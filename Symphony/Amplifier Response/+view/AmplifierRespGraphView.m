classdef AmplifierRespGraphView < handle
    %AMPLIFIERGRAPHVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        controller
        graph
        model
        channels
        subplotHandles = []
    end
    
    methods
        
        function obj = AmplifierRespGraphView(model, controller, layout)
            obj.controller = controller;
            obj.model = model;
            graphPanel = uiextras.BoxPanel(...
                'Title', 'Amplifier Response',...
                'Parent', layout,...
                'BackgroundColor', 'black');
            obj.channels = obj.controller.getChannels;
            n = length(obj.channels);
            for i = 1:n
                obj.subplotHandles(i) = subplot(n, 1, i);
                obj.resetGraph(obj.subplotHandles(i));
            end
        end
        
        function resetGraph(~, graph)
            grid(graph, 'on');
            axis(graph,'tight');
            set(graph, 'XColor', 'White');
            set(graph, 'YColor', 'White');
            set(graph, 'Color', 'black');
        end
        
        function plotGraph(obj, epoch)
            
            for i = 1:length(obj.channels)
                channel = obj.model.plotMap(obj.channels{i});
                if channel.active
                    h = subplot(obj.subplotHandles(i));
                    [x, y] = obj.model.getData(obj.channels{i}, epoch);
                    plot(x, y, 'Color', channel.color, 'ax', h);
                    obj.resetGraph(h);
                end
            end
            drawnow
            %interactive_move
            hold off;
        end
    end
end

