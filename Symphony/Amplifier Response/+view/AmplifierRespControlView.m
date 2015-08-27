classdef AmplifierRespControlView < handle
    %AMPLIFIERRESPCONTROLVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        controller
        channelRadioBtns
        channelListBox
        channelSelectBoxes
        shiftY
        scaleY
        shiftYText
        scaleYText
        thresholdTxt
        directionTxt
    end
    
    methods
        
        function createAmplifierView(obj, layout, model)
            channels = model.channels;
            
            for i = 1:length(channels)
                obj.channelSelectBoxes.(channels{i}) = uicontrol(...,
                    'Parent', layout,...
                    'Style','checkbox',...
                    'String',sprintf('Channel %d',i),...
                    'Value',0,...
                    'callback', @(h,d)updatePlots(obj.controller, model, obj.channelSelectBoxes),...
                    'Tag',channels{i});
            end
        end
        
        function createSpikeDetectorView(obj, labelLayout, controlLayout, model)
            % This method sketches two column view of spike detector layout
            % @related components { obj.channelRadioBtns }
            
            uicontrol(...,
                'Parent', labelLayout,...
                'Style','text',...
                'String','Spike Threshold');
            uicontrol(...,
                'Parent', labelLayout,...
                'Style','pushbutton',...
                'String','Enable', ...
                'callback', @(h, d)enableSpikeDetection(obj.controller, h, d, obj.channelRadioBtns, obj.thresholdTxt, model));
            
            obj.thresholdTxt = uicontrol(...,
                'Parent', controlLayout,...
                'Style','Edit',...
                'String','00.000',...
                'callback', @(h, d)setThreshold(obj.controller, h, d, obj.channelRadioBtns, model));
            uicontrol(...,
                'Parent', controlLayout,...
                'Style','pushbutton',...
                'String','Disable', ...
                'callback', @(h, d)disableSpikeDetection(obj.controller, h, d, obj.channelRadioBtns, obj.thresholdTxt, model));
        end
        
        function createScalingView(obj, layout, model)
            scalingHeader = uiextras.HBox(....
                'Parent', layout);
            
            obj.shiftYText = uicontrol(...,
                'Parent', scalingHeader,...
                'Style', 'text',...
                'String', 'Vertical Shift');
            uicontrol(...,
                'Parent', scalingHeader,...
                'Style', 'text',...
                'String', 'min');
            min = uicontrol(...,
                'Parent', scalingHeader,...
                'Style','Edit',...
                'String','00');
            uicontrol(...,
                'Parent', scalingHeader,...
                'Style', 'text',...
                'String', 'max');
            max = uicontrol(...,
                'Parent', scalingHeader,...
                'Style','Edit',...
                'String','100');
            uicontrol(...,
                'Parent', scalingHeader,...
                'Style','pushbutton',...
                'String','set',...
                'callback', @(h, d) setShiftProperties(obj.controller, h, d, min, max, obj.shiftY, model));
            obj.shiftY = uicontrol(...
                'Parent', layout,...
                'Style','slider',...
                'Min', 0, 'Max', 100, 'Value', 0,...
                'SliderStep', [0.05 0.2],...
                'callback', @(h, d)shiftYAxis(obj.controller, h, d, obj.channelRadioBtns, model));
            obj.scaleYText = uicontrol(...
                'Parent', layout,'Style','text',...
                'String', 'Vertical Scale');
            obj.scaleY = uicontrol(...
                'Parent', layout,'Style','slider',...
                'Min', 1, 'Max', 10, 'Value', 1,...
                'SliderStep', [0.05 0.2],...
                'callback', @(h, d)scaleYAxis(obj.controller, h, d, obj.channelRadioBtns, model),...
                'String', 'Vertical Scale');
        end
        
        function obj = AmplifierRespControlView(model, controller, layout)
            obj.controller = controller;
            obj.channelRadioBtns = struct();
            obj.channelSelectBoxes = struct();
            channels = model.channels;
            
            controlPannel = uiextras.Panel(...
                'Parent', layout,...
                'Title', 'Controls',...
                'Padding', 5 );
            controlsLayout = uiextras.HBoxFlex(...
                'Parent',controlPannel,...
                'Padding', 5, 'Spacing', 5);
            
            amplifierLayout  = uiextras.VBox(....
                'Parent', controlsLayout);
            obj.createAmplifierView(amplifierLayout, model);
            
            amplifierListLabel = uiextras.VBox(....
                'Parent', controlsLayout);
            amplifierList  = uiextras.VBox(....
                'Parent', controlsLayout);
            
            uicontrol(...,
                'Parent', amplifierListLabel,...
                'Style','text',...
                'String','Select channel');
            obj.channelListBox = uicontrol(...,
                'Parent', amplifierList,...
                'Style', 'listbox',...
                'String', channels,...
                'Max', length(channels),...
                'Min', 0,...
                'callback', @(h, d)selectChannel(obj.controller, model, h));
            
            spikeDetecttionLabel  = uiextras.VBox(....
                'Parent', controlsLayout);
            spikeDetecttionLayout  = uiextras.VBox(....
                'Parent', controlsLayout);
            obj.createSpikeDetectorView(spikeDetecttionLabel, spikeDetecttionLayout, model);
            
            
            scalingLayout  = uiextras.VBox(....
                'Parent', controlsLayout);
            obj.createScalingView(scalingLayout, model);
            
            set(controlsLayout, 'Sizes', [100 100 100 100 80 450]);
        end
    end
end

