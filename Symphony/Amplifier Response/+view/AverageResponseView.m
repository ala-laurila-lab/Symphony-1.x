classdef AverageResponseView < view.GraphView
    
    properties(Access = private)
        voltageChkBox
        channelMenu
    end
    
    events
        ShowAverageResponse
    end
    
    methods
        function obj = AverageResponseView()
            obj@view.GraphView([]);
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
                    'callback',@(h, d)notify(obj, 'ShowAverageResponse'));
            end
            
            set(staticControls, 'Sizes', [120 100]);
            set(dynamicControls, 'ColumnSizes',120 * ones(1, n), 'RowSizes', 40);
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

