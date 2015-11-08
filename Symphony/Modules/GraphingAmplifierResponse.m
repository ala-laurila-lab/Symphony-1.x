classdef GraphingAmplifierResponse < Module
    %GRAPHINGAMPLIFIERRESPONSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        displayName = 'Graphing Amplifier Response'
        
        % Colors for the graph
        axesBackgroundColor = [0 0 0];
        gridColor = 'white';
        BackgroundColor = [0.35 0.35 0.35];
    end
    
    properties
        graph
        controls
        amp
        
        % Graph States
        isHolding = false
        isMultiColored = false
        isPaused = false
        gridOn = false
        
        % Graph Data
        graphsAdded = 0
        availableResponses
        responseFields
        graphsToHold = []
        multipleGraphsCanHold = false
        
        % Saving graph
        canSave = false
        graphsToSave = []
        savedGraphs = []
        
        % Axis variables.
        autoAxisEnabled = true
        xAxisMin = 0
        xAxisMax = 0
        yAxisMin = 0
        yAxisMax = 0
        autoAxis
        
        dbScalingFactor = 0
        dbScalingValue
    end
    
    methods
        function obj = GraphingAmplifierResponse(symphonyUI)
            obj = obj@Module(symphonyUI);
            
            if ispref('Symphony', 'Graphing_dB')
                scalingFactor = getpref('Symphony', 'Graphing_dB');
                if scalingFactor == 0 || scalingFactor == 20 || scalingFactor == 10
                    obj.dbScalingFactor = scalingFactor;
                end
            end
            
            obj.amp = obj.symphonyUI.protocol.amp;
            obj.generateAvailableResponses();
            obj.createUI();
            obj.responseCallback();
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
        end
        
        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end
        
        
        function dbScalingValue = get.dbScalingValue(obj)
            switch obj.dbScalingFactor
                case 0
                    dbScalingValue = 1;
                case 10
                    dbScalingValue = 3.1623;
                case 20
                    dbScalingValue = 10;
            end
        end
        
        %% GUI Functions
        function createUI(obj)
            %Construcing the GUI
            clf(obj.figureHandle);
            
            %Deimensions
            figureWidth = 850; %DT Earlier it was 1050
            figureHeight = 400;
            
            checkBoxWidth = 110;
            checkBoxHeight = 15;
            
            position = get(obj.figureHandle, 'Position');
            position(3) = figureWidth;
            position(4) = figureHeight;
            set(obj.figureHandle, 'Position', position);
            %set(obj.figureHandle, 'Resize', 'Off');
            set(obj.figureHandle, 'Color', obj.BackgroundColor);
            set(obj.figureHandle, 'WindowKeyPressFcn', @(hObject, eventdata)setAxisCallback(obj,hObject,eventdata));
            
            obj.graph = axes('Parent',obj.figureHandle,'Position',[.05 .25 .9 .7], 'Color',obj.axesBackgroundColor);
            set(obj.graph, 'XColor', obj.gridColor);
            set(obj.graph, 'YColor', obj.gridColor);
            axis(obj.graph,'tight');
            
            obj.controls = struct();
            obj.controls.responsePanel = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Available Responses', ...
                'Tag', 'responsePanel', ...
                'Clipping', 'on', ...
                'Position', [0 5 125 (5*checkBoxHeight)]);
            
            checkboxYPos = 45;
            checkboxXPos = 2;
            
            % Currently the GUI only has place for six different graphs. So
            % we will take the first 6 in the list (or less if there are
            % less graphs)
            num = min(numel(obj.responseFields), 3);
            
            % Iterate through our graphs and add the checkbox for each one
            for i=1:num
                responseObject = obj.availableResponses.( obj.responseFields{i} );
                paramTag = obj.responseFields{i};
                obj.controls.( paramTag ) = uicontrol(...
                    'Parent', obj.controls.responsePanel, ...
                    'Units', 'points', ...
                    'FontSize', 8, ...
                    'Position', [checkboxXPos checkboxYPos checkBoxWidth checkBoxHeight], ...
                    'String', responseObject.caption, ...
                    'callback', @(hObject,eventdata)responseCallback(obj,hObject,eventdata), ...
                    'Value', responseObject.showResponse, ...
                    'Style', 'checkbox', ...
                    'Tag', obj.responseFields{i});
                
                checkboxYPos = checkboxYPos - 20;
            end
            
            %% Axis Column 2
            obj.controls.axisPanel = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Plot Axis', ...
                'Tag', 'axisPanel', ...
                'Clipping', 'on', ...
                'Position', [125 5 325 (5*checkBoxHeight)]);
            
            uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'Position', [2 35 checkBoxWidth checkBoxHeight], ...
                'String',  'X-Axis Min/Max',...
                'Style', 'text');
            
            uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'Position', [2 15 checkBoxWidth checkBoxHeight], ...
                'String',  'Y-Axis Min/Max',...
                'Style', 'text');
            
            paramTag = 'xAxisMin';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [(checkBoxWidth+2) 35 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.xAxisMin),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'xAxisMin', ...
                'Tag', paramTag);
            
            paramTag = 'xAxisMax';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth/2) 35 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.xAxisMax),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'xAxisMax', ...
                'Tag', paramTag);
            
            paramTag = 'AutoAxis';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)autoAxisCallback(obj,hObject,eventdata), ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth)+ 2 15 checkBoxWidth-35 checkBoxHeight*2+8], ...
                'String', 'Auto Axis (On)', ...
                'TooltipString', 'Auto Axis', ...
                'Tag', 'AutoAxis');
            
            paramTag = 'yAxisMin';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position',[(checkBoxWidth+2) 15 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.yAxisMin),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'yAxisMin', ...
                'Tag', paramTag);
            
            paramTag = 'yAxisMax';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.axisPanel,...
                'Units', 'points', ...
                'FontSize', 12,...
                'HorizontalAlignment', 'left', ...
                'Position', [((checkBoxWidth+2)+checkBoxWidth/2) 15 ((checkBoxWidth - 15)/2) checkBoxHeight], ...
                'String',  num2str(obj.yAxisMax),...
                'Enable', 'off',...
                'Style', 'edit', ...
                'TooltipString', 'yAxisMax', ...
                'Tag', paramTag);
            
            %% Options Column 3
            obj.controls.optionsPanel = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'Plot Options', ...
                'Tag', 'optionsPanel', ...
                'Clipping', 'on', ...
                'Position', [(125 + 325) 5 315 (5 *checkBoxHeight)]);
            
            paramTag = 'overlayResponsesCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 45 checkBoxWidth checkBoxHeight], ...
                'String', 'Overlay Responses', ...
                'Value', 0, ...
                'Enable', 'off', ...
                'callback', @(hObject,eventdata)overlayResponsesCallback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'overlayResponsesCallback');
            
            paramTag = 'showGridCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 25 checkBoxWidth checkBoxHeight], ...
                'String', 'Show Grid', ...
                'Value', obj.gridOn, ...
                'callback', @(hObject,eventdata)showGridCallback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'showGridCallback');
            
            
            paramTag = 'multiColoredHoldCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 5 checkBoxWidth checkBoxHeight], ...
                'String', 'Multi Colored Hold (One Graph Only)', ...
                'Value', 0, ...
                'Enable', 'off', ...
                'callback', @(hObject,eventdata)multiColoredHoldCallback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'multiColoredHoldCallback');
            
            paramTag = 'pauseResponsesCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [(2+checkBoxWidth) 45 checkBoxWidth checkBoxHeight], ...
                'String', 'Pause Responses', ...
                'Value', 0, ...
                'Enable', 'on', ...
                'callback', @(hObject,eventdata)pauseResponsesCallback(obj,hObject,eventdata), ...
                'Style', 'checkbox', ...
                'Tag', 'pauseResponsesCallback');
            
            paramTag = 'saveGraphCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)saveGraphCallback(obj,hObject,eventdata), ...
                'Position', [(2+checkBoxWidth) 5 checkBoxWidth-25 25], ...
                'Enable', 'off', ...
                'String', 'Save Graph', ...
                'TooltipString', 'Save Graph', ...
                'Tag', 'saveGraphCallback');
            
            paramTag = 'eraseGraphCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)eraseGraphCallback(obj,hObject,eventdata), ...
                'Position', [((2*checkBoxWidth)-20) 5 checkBoxWidth 25], ...
                'String', 'Erase Graph', ...
                'TooltipString', 'Erase Graph', ...
                'Tag', 'eraseGraphCallback');
            
            paramTag = 'editGraphCallback';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.optionsPanel,...
                'Units', 'points', ...
                'Callback', @(hObject,eventdata)editGraphCallback(obj,hObject,eventdata), ...
                'Position', [((2*checkBoxWidth)-20) 35 checkBoxWidth 25], ...
                'String', 'Edit Graph', ...
                'TooltipString', 'Edit Graph', ...
                'Tag', 'editGraphCallback');
            
            obj.controls.dB = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', 12, ...
                'Title', 'dB Scaling', ...
                'Tag', 'dBPanel', ...
                'Clipping', 'on', ...
                'Position', [(125 + 325 + 315) 5 135 (5*checkBoxHeight)]);
            
            paramTag = 'dBButtonGroup';
            obj.controls.( paramTag ) = uibuttongroup(...
                'Parent', obj.controls.dB, ...
                'Clipping', 'on', ...
                'SelectionChangeFcn', @(hObject,eventdata)dBCallback(obj,hObject,eventdata), ...
                'Position', [0 0 135 (5*checkBoxHeight)]);
            
            if obj.dbScalingFactor == 10
                radioValue = 1;
            else
                radioValue = 0;
            end
            
            paramTag = 'tendB';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.dBButtonGroup, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 45 checkBoxWidth checkBoxHeight], ...
                'String', '10 dB', ...
                'Value', radioValue, ...
                'Style', 'radiobutton', ...
                'HandleVisibility', 'Off');
            
            if obj.dbScalingFactor == 0
                radioValue = 1;
            else
                radioValue = 0;
            end
            
            paramTag = 'zerodB';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.dBButtonGroup, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 25 checkBoxWidth checkBoxHeight], ...
                'String', '0 dB', ...
                'Value', radioValue, ...
                'Style', 'radiobutton', ...
                'HandleVisibility', 'Off');
            
            if obj.dbScalingFactor == 20
                radioValue = 1;
            else
                radioValue = 0;
            end
            
            paramTag = 'twentydB';
            obj.controls.( paramTag ) = uicontrol(...
                'Parent', obj.controls.dBButtonGroup, ...
                'Units', 'points', ...
                'FontSize', 8, ...
                'Position', [2 5 checkBoxWidth checkBoxHeight], ...
                'String', '20 dB', ...
                'Value', radioValue, ...
                'Style', 'radiobutton', ...
                'HandleVisibility', 'Off');
            
            
        end
        
        %% GUI Interaction Functions
        function setAxisTextEnabledCallback( obj , state )
            set(obj.controls.( 'xAxisMin' ), 'Enable', state);
            set(obj.controls.( 'xAxisMax' ), 'Enable', state);
            set(obj.controls.( 'yAxisMin' ), 'Enable', state);
            set(obj.controls.( 'yAxisMax' ), 'Enable', state);
        end
        
        %To show the grid in the plot, both verticle and horizontal
        function showGridCallback(obj,~,~)
            obj.gridOn = get(obj.controls.showGridCallback, 'Value') == get(obj.controls.showGridCallback, 'Max');
            
            if obj.gridOn == 1
                set(obj.graph,'XGrid','on')
                set(obj.graph,'YGrid','on')
            else
                set(obj.graph,'XGrid','off')
                set(obj.graph,'YGrid','off')
            end
        end
        
        % the erase graph button
        function eraseGraphCallback(obj,~,~)
            for g = 1:length(obj.savedGraphs)
                line = findobj('DisplayName',['save ' num2str(g)]);
                delete(line);
            end
            
            obj.savedGraphs = [];
            obj.clearFigure;
        end
        
        % This launches the plottools functionality
        function editGraphCallback(obj,~,~)
            plotedit(obj.graph, 'on');
            plottools;
        end
        
        function multiColoredHoldCallback(obj,~,~)
            obj.isMultiColored = get(obj.controls.multiColoredHoldCallback, 'Value') == get(obj.controls.multiColoredHoldCallback, 'Max');
        end
        
        function responseCallback(obj,~,~)
            obj.graphsAdded = 0;
            obj.canSave = false;
            obj.multipleGraphsCanHold = false;
            
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                
                responseObject.showResponse = get(obj.controls.(paramTag), 'Value') == get(obj.controls.(paramTag), 'Max');
                
                if responseObject.showResponse
                    obj.graphsAdded = obj.graphsAdded + 1;
                    if responseObject.canSave
                        obj.canSave = true;
                    end
                    
                    if responseObject.multipleGraphsCanHold
                        obj.multipleGraphsCanHold = true;
                    end
                end
            end
            
            if obj.graphsAdded == 1 || obj.multipleGraphsCanHold
                set(obj.controls.overlayResponsesCallback, 'Enable', 'on');
            elseif obj.graphsAdded ==0
                set(obj.controls.overlayResponsesCallback, 'Enable', 'off');
                set(obj.controls.overlayResponsesCallback, 'Value', false);
                obj.isHolding = false;
            end
            
            if (obj.graphsAdded > 1 || obj.graphsAdded == 0)
                obj.isMultiColored = false;
                set(obj.controls.multiColoredHoldCallback, 'Value', false);
                set(obj.controls.multiColoredHoldCallback, 'Enable', 'off');
            elseif obj.isHolding
                set(obj.controls.multiColoredHoldCallback, 'Enable', 'on');
            end
            
            if obj.canSave
                set(obj.controls.saveGraphCallback, 'Enable', 'on');
            else
                set(obj.controls.saveGraphCallback, 'Enable', 'off');
            end
            
        end
        
        % If you have 1 graph, you can overlay each epochs responses
        function overlayResponsesCallback(obj,~,~)
            obj.isHolding = get(obj.controls.overlayResponsesCallback, 'Value') == get(obj.controls.overlayResponsesCallback, 'Max');
            
            if obj.graphsAdded > 1 || ~obj.isHolding
                obj.isMultiColored = false;
                set(obj.controls.multiColoredHoldCallback, 'Value', false);
                set(obj.controls.multiColoredHoldCallback, 'Enable', 'off');
            elseif obj.isHolding
                set(obj.controls.multiColoredHoldCallback, 'Enable', 'on');
            end
        end
        
        function saveGraphCallback(obj,~,~)
            for g = 1:length(obj.graphsToSave)
                responseObject = obj.availableResponses.( char(obj.graphsToSave(g)) );
                obj.savedGraphs{end + 1} = responseObject.lastPlot;
            end
        end
        
        % To pause the pgraphing (ie. to stop graphing and hold the currently drawn figure)
        function pauseResponsesCallback(obj,~,~)
            obj.isPaused = get(obj.controls.pauseResponsesCallback, 'Value') == get(obj.controls.pauseResponsesCallback, 'Max');
        end
        
        function autoAxisCallback(obj,~,~)
            if obj.autoAxisEnabled
                obj.autoAxisEnabled = false;
                set(obj.controls.( 'AutoAxis' ), 'String', 'Auto Axis (Off)');
                obj.setAxisTextEnabledCallback('on');
                axis(obj.graph,'manual');
            else
                obj.autoAxisEnabled = true;
                set(obj.controls.( 'AutoAxis' ), 'String', 'Auto Axis (On)');
                obj.setAxisTextEnabledCallback('off');
                axis(obj.graph,'tight');
            end
            
            obj.setAxis;
        end
        
        function setAxisCallback( obj , ~ , eventdata )
            if strcmp(eventdata.Key, 'return')
                pause(0.01);
                obj.setAxis;
            end
        end
        
        function dBCallback(obj,~,eventdata)
            switch get(eventdata.NewValue,'String')
                case '0 dB'
                    dB = 0;
                case '10 dB'
                    dB = 10;
                case '20 dB'
                    dB = 20;
            end
            
            obj.dbScalingFactor = dB;
            setpref('Symphony', 'Graphing_dB', dB);
        end
        
        %% Utility Functions
        function setAxis(obj)
            try
                if obj.autoAxisEnabled
                    obj.autoAxis = axis(obj.graph);
                    obj.xAxisMin = obj.autoAxis(1);
                    obj.xAxisMax = obj.autoAxis(2);
                    obj.yAxisMin = obj.autoAxis(3);
                    obj.yAxisMax = obj.autoAxis(4);
                else
                    obj.xAxisMin = str2num(get(obj.controls.( 'xAxisMin' ), 'String')); %#ok<ST2NM>
                    obj.xAxisMax = str2num(get(obj.controls.( 'xAxisMax' ), 'String')); %#ok<ST2NM>
                    obj.yAxisMin = str2num(get(obj.controls.( 'yAxisMin' ), 'String')); %#ok<ST2NM>
                    obj.yAxisMax = str2num(get(obj.controls.( 'yAxisMax' ), 'String')); %#ok<ST2NM>
                    
                end
                
                set(obj.controls.( 'xAxisMin' ), 'String', obj.xAxisMin);
                set(obj.controls.( 'xAxisMax' ), 'String', obj.xAxisMax);
                set(obj.controls.( 'yAxisMin' ), 'String', obj.yAxisMin);
                set(obj.controls.( 'yAxisMax' ), 'String', obj.yAxisMax);
                axis(obj.graph, [obj.xAxisMin,obj.xAxisMax,obj.yAxisMin,obj.yAxisMax]);
            catch
                % There maybe an error with the Java callback, Lets do
                % nothing, leave the values as they were
            end
        end
        
        function removeResponses(obj, newRun)
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                try
                    if (obj.graphsAdded > 1 && (~obj.isHolding || ~responseObject.multipleGraphsCanHold)) || ...
                            ~obj.isHolding &&  obj.graphsAdded == 1 || newRun
                        line = findobj('DisplayName',paramTag);
                        delete(line);
                    end
                catch
                end
            end
        end
        
        function clearFigure(obj)
            obj.removeResponses(true);
            
            for i=1:numel(obj.responseFields)
                paramTag =  obj.responseFields{i};
                responseObject = obj.availableResponses.( paramTag );
                responseObject.clearFigure();
            end
            set(get(obj.graph,'title'),'string',''); %DT
            obj.checkingForGrid;
            obj.addSavedGraphs;
        end
        
        function addSavedGraphs(obj)
            hold(obj.graph, 'all');
            for g = 1:length(obj.savedGraphs)
                name = ['save ' num2str(g)];
                
                if isempty(findobj('DisplayName',name))
                    lastPlot = obj.savedGraphs{g};
                    plot(obj.graph,lastPlot.XData,lastPlot.YData,'DisplayName',name);
                    set(obj.graph,'Color',obj.axesBackgroundColor);
                    set(obj.graph, 'XColor', obj.gridColor);
                    set(obj.graph, 'YColor', obj.gridColor);
                    axis(obj.graph,'tight') ;
                    obj.setAxis;
                    drawnow;
                end
            end
            hold(obj.graph, 'off');
        end
        
        function run(obj)
            if ~obj.autoAxisEnabled
                obj.setAxisTextEnabledCallback('off');
            end
            
            if obj.canSave
                set(obj.controls.saveGraphCallback, 'Enable', 'off');
            end
        end
        
        function completeRun(obj)
            if ~obj.autoAxisEnabled
                obj.setAxisTextEnabledCallback('on');
            end
            
            if obj.canSave
                set(obj.controls.saveGraphCallback, 'Enable', 'on');
            end
        end
        
        function holdState = getHoldState(obj)
            if obj.isHolding && obj.isMultiColored || obj.graphsAdded > 1
                holdState = 'all';
            else
                holdState = 'on';
            end
        end
        %% Graphing Functions
        function checkingForGrid(obj)
            if obj.gridOn
                set(obj.graph,'XGrid','on')
                set(obj.graph,'YGrid','on')
                set(obj.graph, 'XColor', obj.gridColor);
                set(obj.graph, 'YColor', obj.gridColor);
            end
            
        end
        
        % This is called by petri protocol passing the necessary
        % information for plotting the data
        function handleEpoch(obj, epoch)
            obj.removeResponses(false);
            obj.amp = obj.symphonyUI.protocol.amp;
            graphResponses( obj , epoch );
        end
        
        
        % The function that draws the responses returned from th eselect
        % responses
        function graphResponses(obj, epoch)
            if obj.graphsAdded > 0 && ~obj.isPaused
                obj.checkingForGrid;
                
                for i=1:numel(obj.responseFields)
                    paramTag =  obj.responseFields{i};
                    responseObject = obj.availableResponses.( paramTag );
                    
                    if responseObject.showResponse
                        [XData , YData] = responseObject.response(obj.symphonyUI.protocol, epoch , obj.amp , obj.dbScalingValue);
                        
                        if ~isempty(XData) || ~isempty(YData)
                            hold(obj.graph, obj.getHoldState);
                            if obj.graphsAdded >= 1
                                plot(obj.graph,XData,YData,'Color',responseObject.lineColor,'DisplayName',paramTag);
                                %                             else
                                %                                 plot(obj.graph,XData,YData,'DisplayName',paramTag);
                            end
                            set(obj.graph,'Color',obj.axesBackgroundColor);
                            set(obj.graph, 'XColor', obj.gridColor);
                            set(obj.graph, 'YColor', obj.gridColor);
                            axis(obj.graph,'tight') ;
                            obj.setAxis;
                            %Start changes by DT
                            if isfield(epoch.parameters, 'StimAmp')%show stimulus parameters as title
                                nepohc_all = epoch.parameters.numberOfIntensities*epoch.parameters.numberOfRepeats;
                                stim_para = sprintf('%gmV-%dInts-%dReps',epoch.parameters.initialPulseAmplitude,...
                                    epoch.parameters.numberOfIntensities, epoch.parameters.numberOfRepeats);
                                % str_title = sprintf('Epoch%d/%d: %g mV Temp:%4.1fC, %s',epoch.parameters.numberOfEpochsCompleted,nepohc_all, ...
                                % epoch.parameters.StimAmp,epoch.parameters.Temp, stim_para);
                                str_title = sprintf('Total epoch %d: %g mV Temp:%4.1fC, %s',nepohc_all, ...
                                    epoch.parameters.StimAmp,epoch.parameters.Temp, stim_para);
                                set(get(obj.graph, 'title'),'string',str_title,...
                                    'Color',[1 1 1],'FontSize',16);
                            end
                            % End changes by DT
                            drawnow;
                        end
                        hold(obj.graph, 'off');
                    end
                    
                    for g = 1:length(obj.savedGraphs)
                        name = ['save ' num2str(g)];
                        line = findobj('DisplayName',name);
                        uistack(line, 'top');
                    end
                end
            end
        end
        
        function generateAvailableResponses(obj)
            obj.availableResponses = struct();
            responseDir = fullfile(regexprep(userpath, ';', ''), 'Symphony', 'Graph Responses');
            responseList = dir(responseDir);
            responseListLength = length(responseDir);
            
            if responseListLength > 2
                for d = 3:length(responseList)
                    name = responseList(d).name;
                    extension = '.m';
                    
                    if strfind(name, extension)
                        name = strrep(name, extension, '');
                        constructor = str2func(name);
                        obj.availableResponses.( name ) = constructor();
                    end
                    
                    if obj.availableResponses.( name ).canSave
                        obj.canSave = true;
                        obj.graphsToSave{end + 1} = name;
                    end
                    
                    if obj.availableResponses.( name ).multipleGraphsCanHold
                        obj.multipleGraphsCanHold = true;
                        obj.graphsToHold{end + 1} = name;
                    end
                end
            end
            
            obj.responseFields = fieldnames(obj.availableResponses);
        end
    end
end

