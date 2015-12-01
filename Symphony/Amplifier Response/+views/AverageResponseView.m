classdef AverageResponseView < views.GraphView
    
    properties(Access = private)
        voltageChkBox
        channelMenu
        selectAllVoltagesChkBox
    end
    
    events
        ShowAverageResponse
        HoldAverageResponse
        EraseHoldingResponse
        ShowAllAverageResponse
    end
    
    methods
        function obj = AverageResponseView()
            obj@views.GraphView([]);
            set(obj.figureHandle, 'Name', 'Average Response');
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
                'callback',@(h, d)notify(obj, 'ShowAverageResponse'));
            
            holdGraphControls = uiextras.HButtonBox(...,
                'Parent', staticControls,...
                'HorizontalAlignment', 'left');
            
            uicontrol(....
                'Parent', holdGraphControls,...
                'String', 'Save Graph',...
                'callback',@(h, d)notify(obj, 'HoldAverageResponse'));
            
            uicontrol(....
                'Parent', holdGraphControls,...
                'String', 'Erase Graph',...
                'callback',@(h, d)notify(obj, 'EraseHoldingResponse'));
            
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
                'Value',0,...
                'callback',@(h, d)notify(obj, 'ShowAllAverageResponse'));
            
            uiextras.Empty('Parent', legendControls);

            n = length(voltages);
            obj.voltageChkBox = cell(1, n);
            
            for i = 1:n
                obj.voltageChkBox{i} = uicontrol(...,
                    'Parent', dynamicControls,...
                    'Style','checkbox',...
                    'String',sprintf('%d mv',voltages(i)),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'ShowAverageResponse'));
                uicontrol(...
                    'BackgroundColor', Colors.getBackGround(),...
                    'ForegroundColor', legends{i}.getValue(),...
                    'Parent', legendControls,...
                    'String', '====' );
            end
            
            set(staticControls, 'Sizes', [120 100, 300]);
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

