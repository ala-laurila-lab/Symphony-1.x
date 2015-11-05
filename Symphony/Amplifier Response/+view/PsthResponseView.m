classdef PsthResponseView <  view.GraphView
    
    properties(Access = private)
        channelMenu
        voltageChkBox
        smoothingWindowTxt
    end
    
    events
        ShowPsthResponse
    end
    
    methods
        
        function obj = PsthResponseView()
            obj@view.GraphView([]);
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
                'String','00.000',...
                'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
            
            uicontrol(...,
                'Parent', controlLayout,...
                'Style','text',...
                'HorizontalAlignment', 'left',...
                'String','Select Intensity Level');
            
            dynamicControls = uiextras.Grid(...
                'Parent', controlLayout,...
                'Padding', 5, 'Spacing', 5);
            
            n = length(voltages);
            obj.voltageChkBox = cell(1, n);
            for i = 1:n
                obj.voltageChkBox{i} = uicontrol(...,
                    'Parent', dynamicControls,...
                    'Style','checkbox',...
                    'String',sprintf('%d mv (%s)',voltages(i), legends{i}),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
            end
            
            set(staticControls, 'Sizes', [120 100 120 100]);
            set(dynamicControls, 'ColumnSizes', 120 * ones(1, n), 'RowSizes', 40);
            set(controlLayout, 'Sizes', [-1 -0.3 -1]);
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
        
        %TODO try to optimize with cellarray fun
        function idx = getSelectedVoltageIndex(obj)
            c = obj.voltageChkBox;
            idx = [];
            for i= 1:length(c)
                if get(c{i}, 'Value') == 1
                    idx = [idx, i];
                end
            end
        end
    end
end

