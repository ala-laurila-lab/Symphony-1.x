classdef PsthRespView < handle
    %SPIKEDETECTORVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        figureHandle
        graph
        intensityChkBox
    end
    
    properties(Access = private)
        intensityLayout
        graphLayout
    end
    
    events
        selectIntensity
        psthResponse
    end
    
    methods
        function obj = PsthRespView
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
                'Spacing', 1);
            set(layout, 'Sizes', [100 -1]);
        end
        
        function show(obj, status, intensities, channels, legend)
            if status
                set(obj.figureHandle, 'Visible', 'on');
            else
                set(obj.figureHandle, 'Visible', 'off');
            end
            obj.showIntensity(intensities, legend)
            obj.displayGraph(channels);
        end
        
        function clear(obj)
            if ~isempty(obj.intensityChkBox) && ~isempty(obj.graph)
                cellfun(@(chkBox) delete(chkBox), obj.intensityChkBox);
                structfun(@(axes) delete(axes), obj.graph);
            end
        end
        
        function showIntensity(obj, intensities, legend)
            n = length(intensities);
            obj.intensityChkBox = cell(1, n);
            
            for i = 1:n
                obj.intensityChkBox{i} = uicontrol(...,
                    'Parent', obj.intensityLayout,...
                    'Style','checkbox',...
                    'String',sprintf('%d mv (%s)',intensities(i), legend{i}),...
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

        function renderGraph(obj)
            drawnow
            %interactive_move
            structfun(@(axes) hold(axes, 'off'), obj.graph);
        end
        
        function plotPSTH(obj, channel, x, y, color)
            axes = obj.graph.(channel);
            plot(axes, x, y, 'color', color);
            obj.resetGraph(axes);
            hold on;
        end
    end
end

