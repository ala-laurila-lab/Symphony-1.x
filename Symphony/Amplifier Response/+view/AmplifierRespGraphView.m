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
            channels = obj.model.plotMap.keys;
            
            for i = 1:length(channels)
                channelInfo = obj.model.plotMap(channels{i});
                
                if channelInfo.active
                    [x, y, threshold, spike_x, spike_y] = obj.model.getData(channels{i}, epoch);
                    h = plot(obj.graph, x, y, 'color', channelInfo.color);
                    
                    if ~isempty(spike_x)
                        hold(obj.graph, 'on')
                        plot(obj.graph, spike_x, spike_y, 'b*');
                    end
                    refline(obj.graph, [0 threshold]);
                    hold(obj.graph, 'on');
                    obj.resetGraph;
                end
            end
            drawnow
            interactive_move
            hold(obj.graph, 'off');
        end
    end
end

