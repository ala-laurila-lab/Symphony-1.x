classdef GraphView < View
    
    properties(Access = protected)
        infoLayout
        graph
        controlsLayout
    end
    
    methods

        function obj = GraphView(figureHandle)
            obj@View(figureHandle);
        end
                
        function createUi(obj)
            layout = uiextras.VBox('Parent', obj.figureHandle);  
            obj.infoLayout = uiextras.HBox('Parent',layout);      % Information layout - to display some epoch statistics
            graphPanel = uiextras.BoxPanel(...
                'Title', 'Amplifier Response',...
                'Parent', layout,...
                'BackgroundColor', 'black');
            obj.graph = axes(...
                'Parent', graphPanel, ...
                'ActivePositionProperty', 'OuterPosition');
            obj.resetGraph();
            obj.controlsLayout = uiextras.HBox('Parent',layout);  % Overidden by subclass for specific graph controls
            set(layout, 'Sizes', [-0.5 -5 100]);
        end
        
        function setInfoLayout(~)
            % Sub class will override this method for specifc Information
        end
        
        function setControlsLayout(~)
            % Sub class will override this method for specifc controls
        end
       
        function resetGraph(obj)
            grid(obj.graph, 'on');
            axis(obj.graph,'tight');
            set(obj.graph, 'XColor', 'White');
            set(obj.graph, 'YColor', 'White');
            set(obj.graph, 'Color', 'black');
        end
        
        function renderGraph(obj)
            drawnow
            %interactive_move
            hold(obj.graph, 'off');
        end
        
        function plot(obj, x , y, key, value)
            plot(obj.graph, x, y, key, value);
            hold(obj.graph, 'on');
        end       
        
        function refline(obj, x, threshold)
            y_threshold = threshold * ones(1, length(x));
            plot(obj.graph, x, y_threshold, 'color', 'blue');
            hold(obj.graph, 'on');
        end
        
        function id = getActiveComponentsByTagName(obj, uiComponents)
            filter = @(x) x.Value == 1;
            components = obj.getValues(uiComponents, filter);
            id = get(components, 'Tag');
        end
        
        function v = getValues(~, s, filter)
            f = fieldnames(s);
            v = [];
            
            for i = 1:length(f)
                c = get(s.(f{i}));
                if isempty(filter) || filter(c)
                    v = [v, s.(f{i})];
                end
            end
        end
    end
end

