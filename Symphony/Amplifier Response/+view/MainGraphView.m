classdef MainGraphView < view.GraphView
    
    properties(Access = private)
        amplifierCheckBox
        thresholdText
        spikeDetectionEnabledBtn
        spikeDetectionDisabledBtn
        psthResponseChkBox
        avgResponseChkBox
    end
    
    events
        UpdateSelectedAmplifiers
        StartSpikeDetection
        StopSpikeDetection
        SetThreshold
        ShowPsthResponse
        ShowAvgResponse
    end
    
    methods
        
        function obj = MainGraphView(figureHandle)
            obj@view.GraphView(figureHandle);
        end
        
        function setInfoLayout(~)
            % Sub class will override this method for specifc Information
        end
        
        function setControlsLayout(obj, channels)
            
            controlPannel = uiextras.HBox(...
                'Parent', obj.controlsLayout,...
                'Padding', 5, 'Spacing', 5);
            
            amplifierLayout  = uiextras.VBox('Parent', controlPannel);
            n = length(channels);
            obj.amplifierCheckBox = cell(1, n);
            for i = 1:n
                obj.amplifierCheckBox{i} = uicontrol(...,
                    'Parent', amplifierLayout,...
                    'Style','checkbox',...
                    'String',sprintf('Channel %d',i),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'UpdateSelectedAmplifiers', util.EventData(channels{i}, get(h, 'Value'))),...
                    'Tag',channels{i});
            end
            
            spikeDetectionLabel  = uiextras.VBox('Parent', controlPannel);
            spikeDetectionControl  = uiextras.VBox('Parent', controlPannel);
            uicontrol(...,
                'Parent', spikeDetectionLabel,...
                'Style','text',...
                'String','Spike Threshold');
            obj.spikeDetectionEnabledBtn = uicontrol(...,
                'Parent', spikeDetectionLabel,...
                'Style','pushbutton',...
                'String','Enable', ...
                'Value', 1,...
                'callback',@(h, d)notify(obj, 'StartSpikeDetection'));
            
            obj.thresholdText = uicontrol(...,
                'Parent', spikeDetectionControl,...
                'Style','Edit',...
                'String','00.000',...
                'callback',@(h, d)notify(obj, 'SetThreshold'));
            obj.spikeDetectionDisabledBtn = uicontrol(...,
                'Parent', spikeDetectionControl,...
                'Style','pushbutton',...
                'String','Disable', ...
                'Value', 0,...
                'callback',@(h, d)notify(obj, 'StopSpikeDetection'));
            
            otherPlotsLayout = uiextras.Grid(...
                'Parent', controlPannel,...
                'Padding', 5,...
                'Spacing', 5);
            obj.psthResponseChkBox = uicontrol(...,
                'Parent', otherPlotsLayout,...
                'Style','checkbox',...
                'String','PSTH Response',...
                'Value',0,...
                'callback',@(h, d)notify(obj, 'ShowPsthResponse'));
            obj.avgResponseChkBox = uicontrol(...,
                'Parent', otherPlotsLayout,...
                'Style','checkbox',...
                'String','Average Response',...
                'Value',0,...
                'callback',@(h, d)notify(obj, 'ShowAvgResponse'));
            set(controlPannel, 'Sizes', [80 100 100 300]);
        end
        
        function t = getSpikeThreshold(obj)
            t = str2double(get(obj.thresholdText, 'String'));
        end
        
        function tf = hasAvgResponseChecked(obj)
            tf = get(obj.avgResponseChkBox, 'value');
        end
        
        function tf = hasPSTHResponseChecked(obj)
            tf = get(obj.psthResponseChkBox, 'value');
        end
        
        function plotSpike(obj, x, y, props)
            plot(obj.graph, x, y, props('marker'));
            hold(obj.graph, 'on');
        end
    end
    
end

