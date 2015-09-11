classdef SpikeStatisticsView < handle
    %SPIKEDETECTORVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        figureHandle
        graph
    end
    
    properties(Access = private)
        intensityLayout
        graphLayout
    end
    
    events
        selectIntensity
    end
    
    methods
        function obj = SpikeStatisticsView
            createUi(obj);
        end
        
        function createUi(obj)
            obj.graph = struct();
            obj.figureHandle = figure( ...
                'Name', 'PSTH Response', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off',...
                'Visible', 'off');
            
            layout = uiextras.VBox(...
                'Parent', obj.figureHandle,...
                'Padding', 5,...
                'Spacing', 5);
            
            obj.intensityLayout = uiextras.HBox(...,
                'Parent', layout,...
                'Padding', 5,...
                'Spacing', 5);
            obj.graphLayout = uiextras.Grid(...,
                'Parent', layout,...
                'BackgroundColor', 'black',...
                'Padding', 1,...
                'Spacing', 1)
            set(layout, 'Sizes', [100 -1]);
        end
        
        function show(obj, status, channels)
            if status
                set(obj.figureHandle, 'Visible', 'on');
            else
                set(obj.figureHandle, 'Visible', 'off');
            end
            displayGraph(obj, channels);
        end
        
        function showIntensity(obj, intensities)
            
            for i = 1:length(intensities)
                uicontrol(...,
                    'Parent', obj.intensityLayout,...
                    'Style','checkbox',...
                    'String',sprintf('%d mv',intensities(i)),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'selectIntensity', util.EventData(i, get(h, 'Value'))));
            end
        end
        
        function displayGraph(obj, channels)
            
            for i = 1:length(channels)
                ax = axes(...
                    'Parent', obj.graphLayout, ...
                    'ActivePositionProperty', 'OuterPosition');
                obj.resetGraph(ax);
                obj.graph.(channels{i}) = ax;
            end
        end
        
        function resetGraph(~, axes)
            grid(axes, 'on');
            axis(axes,'tight');
            set(axes, 'XColor', 'White');
            set(axes, 'YColor', 'White');
            set(axes, 'Color', 'black');
        end
        
        function plotPSTH(channel, x, y)
            axes = obj.graph.(channel);
            axes.plot(x, y);
            obj.restGraph(axes);
        end
    end
end

