classdef GraphView < View
    
    properties(Access = protected)
        layout
        infoLayout
        graph
        controlsLayout
        titleText
    end
    
    methods
        
        function obj = GraphView(figureHandle)
            obj@View(figureHandle);
        end
        
        function createUi(obj)
            % Restore the previous window position.
            prefName = matlab.lang.makeValidName(class(obj));
            pref = [prefName '_Position'];
            if ispref('Symphony', pref)
                position = getpref('Symphony', pref);
                set(obj.figureHandle, 'Position', position);
            end
            
            % Create tool bar only with zoom and pan icon
            set(obj.figureHandle, 'toolbar','figure');
            guiObjs = findall(obj.figureHandle);
            disableToolBarList = {...
                'Show Plot Tools',...
                'Hide Plot Tools',...
                'Print Figure',...
                'Save Figure',...
                'Open File',...
                'New Figure',...
                'Insert Legend',...
                'Insert Colorbar',...
                'Data Cursor',...
                'Rotate 3D',....
                'Edit Plot',...
                'Brush/Select Data',...
                'Link Plot',...
                'Show Plot Tools and Dock Figure',...
                'Zoom Out'};
            
            for i = 1:length(disableToolBarList)
                toolBarObj = findall(guiObjs,'ToolTipString', disableToolBarList{i});
                if ~isempty(toolBarObj)
                    set(toolBarObj, 'Visible', 'off');
                end
            end
            
            obj.layout = uiextras.VBox('Parent', obj.figureHandle);
            % Information layout - to display some epoch statistics
            obj.infoLayout = uiextras.HBox('Parent',obj.layout);
            
            graphPanel = uiextras.BoxPanel(...
                'Title', 'Amplifier Response',...
                'Parent', obj.layout,...
                'BackgroundColor', 'black');
            obj.graph = axes(...
                'Parent', graphPanel, ...
                'ActivePositionProperty', 'OuterPosition');
            obj.resetGraph();
            
            % Overidden by subclass for specific graph controls
            obj.controlsLayout = uiextras.HBox('Parent',obj.layout);
            set(obj.layout, 'Sizes', [0.1 -5 100]);
        end
        
        function setInfoLayout(~)
            % Sub class will override this method for specifc Information
        end
        
        function setControlsLayout(~)
            % Sub class will override this method for specifc controls
        end
        
        %TODO try to optimize with cellarray fun
        function idx = getSelectedCheckBoxIndices(~, c)
            idx = [];
            for i= 1:length(c)
                if get(c{i}, 'Value') == 1
                    idx = [idx, i];
                end
            end
        end
        
        function tf = isZoomed(obj)
            h = zoom(obj.figureHandle);
            tf = strcmp(get(h, 'Enable'), 'on');
        end
        
        function resetGraph(obj)
            grid(obj.graph, 'on');
            
            if ~ obj.isZoomed()
                axis(obj.graph,'tight');
            end
            set(obj.graph, 'XColor', 'White');
            set(obj.graph, 'YColor', 'White');
            set(obj.graph, 'Color', 'black');
        end
        
        function renderGraph(obj)
            drawnow
            hold(obj.graph, 'off');
        end
        
        function plot(obj, x , y, key, value)
            
            xLimit = 'auto'; yLimit = 'auto';
            if obj.isZoomed()
                xLimit = get(obj.graph ,'XLim');
                yLimit = get(obj.graph ,'YLim');
            end
            
            plot(obj.graph, x, y, key, value);
            hold(obj.graph, 'on');
            xlim(obj.graph, xLimit);
            ylim(obj.graph, yLimit);
            
            if ~ isempty(obj.titleText)
                title(obj.graph, obj.titleText, 'Color', 'White');
            end
        end
        
        function refline(obj, x, threshold)
            y_threshold = threshold * ones(1, length(x));
            plot(obj.graph, x, y_threshold, 'color', 'red');
            hold(obj.graph, 'on');
        end
        
        function saveFigureHandlePosition(obj)
            prefName = matlab.lang.makeValidName(class(obj));
            setpref('Symphony', [prefName '_Position'], get(obj.figureHandle, 'Position'));
        end
        
        function clearGraph(obj)
            cla(obj.graph, 'reset')
        end
    end
end
