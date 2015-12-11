classdef PsthResponseView <  views.GraphView
    
    properties(Access = private)
        channelMenu
        voltageChkBox
        smoothingWindowTxt
        selectAllVoltagesChkBox
    end
    
    events
        ShowPsthResponse
        ShowAllPsthResponse
    end
    
    methods
        
        function obj = PsthResponseView()
            obj@views.GraphView([]);
            set(obj.figureHandle, 'Name', 'PSTH Response');
        end
        
        function setControlsLayout(obj, voltages, channels)
            import constants.*;
            legends = GraphingConstants.COLOR_SET.cell;
            
            controlLayout = uiextras.VBox('Parent', obj.controlsLayout);
            staticControls = uiextras.HBox('Parent', controlLayout);
            
            uicontrol(...,
                'Parent', staticControls,...
                'Style','text',...
                'HorizontalAlignment', 'left',...
                'String','Amplifier Channel');
            
            obj.channelMenu = uicontrol(...
                'Parent',staticControls,...
                'Style', 'popup',...
                'String', channels,...
                'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
            
            uicontrol(...,
                'Parent', staticControls,...
                'Style','text',...
                'String','Smoothing Window');
            
            obj.smoothingWindowTxt = uicontrol(...,
                'Parent', staticControls,...
                'Style','Edit',...
                'String','200',...
                'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
            
            uicontrol(...,
                'Parent', controlLayout,...
                'Style','text',...
                'HorizontalAlignment', 'left',...
                'String','Select Intensity Level');
            
            dynamicControls = uiextras.Grid(...
                'Parent', controlLayout,...
                'Padding', 5, 'Spacing', 5);
            
            legendControls = uiextras.HButtonBox(...,
                'Parent', controlLayout,...
                'HorizontalAlignment', 'left');
            
            obj.selectAllVoltagesChkBox = uicontrol(...,
                'Parent', dynamicControls,...
                'Style','checkbox',...
                'String','All',...
                'Value', 1,...
                'callback',@(h, d)notify(obj, 'ShowAllPsthResponse'));
            
            uiextras.Empty('Parent', legendControls);
            
            n = length(voltages);
            obj.voltageChkBox = cell(1, n);
            for i = 1:n
                obj.voltageChkBox{i} = uicontrol(...,
                    'Parent', dynamicControls,...
                    'Style','checkbox',...
                    'String',sprintf('%d mv',voltages(i)),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
                uicontrol(...
                    'BackgroundColor', Colors.getBackGround(),...
                    'ForegroundColor', legends{i}.getValue(),...
                    'Parent', legendControls,...
                    'String', '====' );
            end
            
            set(staticControls, 'Sizes', [120 100 120 100]);
            set(dynamicControls, 'ColumnSizes', 80 * ones(1, n), 'RowSizes', 40);
            set(legendControls, 'ButtonSize', [80 35], 'Spacing', 5);
            set(controlLayout, 'Sizes', [-0.7 -0.3 -1 -0.5]); % -0.3 corresponds to text 'Select Intensity level'
        end
        
        function clearControlsLayout(obj)
            if ~isempty(obj.voltageChkBox)
                cellfun(@(chkBox) delete(chkBox), obj.voltageChkBox);
            end
        end
        
        function channel = getSelectedChannel(obj)
            channels = get(obj.channelMenu,'String');
            idx = get(obj.channelMenu,'Value');
            channel = channels{idx};
        end
        
        function v = getSmoothingWindow(obj)
            str = get(obj.smoothingWindowTxt, 'String');
            v = str2double(str);
        end
        
        function idx = getSelectedVoltageIndex(obj)
            c = obj.voltageChkBox;
            idx = obj.getSelectedCheckBoxIndices(c);
        end
        
        function setAllVoltages(obj, value)
            cellfun(@(chkBox) set(chkBox, 'Value', value) , obj.voltageChkBox);
        end
        
        function tf = hasAllVoltagesChecked(obj)
            tf = get(obj.selectAllVoltagesChkBox,'Value');
        end
    end
end

