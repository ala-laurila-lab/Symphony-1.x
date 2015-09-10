classdef AmpRespView < handle
    %AMPRESPVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        figureHandle
        infoLayout
        graph
        channelChkBoxes
        thresholdTxt
        spikeDetectionEnabled
        spikeDetectionDisabled
    end
    
    events
        updateAmplifiers
        startSpikeDetection
        stopSpikeDetection
        setThreshold
        plotSpikeStats
    end
    
    methods
        
        function obj = AmpRespView(figureHandle)
            obj.figureHandle = figureHandle;
        end
        
        function render(obj, channels)
            layout = uiextras.VBox(...
                'Parent', obj.figureHandle);
            obj.infoLayout = uiextras.HBox('Parent',layout);
            obj.graphView(layout);
            obj.resetGraph;
            obj.controlView(layout, channels);
            set(layout, 'Sizes', [-0.5 -5 120]);
        end
        
        function graphView(obj, layout)
            graphPanel = uiextras.BoxPanel(...
                'Title', 'Amplifier Response',...
                'Parent', layout,...
                'BackgroundColor', 'black');
            obj.graph = axes(...
                'Parent', graphPanel, ...
                'ActivePositionProperty', 'OuterPosition');
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
        
        function plotEpoch(obj, x , y, props)
            plot(obj.graph, x, y, 'color', props('color'));
            hold(obj.graph, 'on');
        end
        
        function plotSpike(obj, x , y, threshold, props)
            plot(obj.graph, x, y, props('style'));
            hold(obj.graph, 'on');
            refline(obj.graph, [0 threshold]);
        end
    end
    
    methods
        
        function controlView(obj, layout, channels)
            controlPannel = uiextras.Panel(...
                'Parent', layout,...
                'Title', 'Controls',...
                'Padding', 5 );
            controlsLayout = uiextras.HBoxFlex(...
                'Parent',controlPannel,...
                'Padding', 5, 'Spacing', 5);
            
            amplifierLayout  = uiextras.VBox(....
                'Parent', controlsLayout);
            obj.createCheckbox(amplifierLayout, channels);
            
            spikeDetecttionLabel  = uiextras.VBox(....
                'Parent', controlsLayout);
            spikeDetecttionLayout  = uiextras.VBox(....
                'Parent', controlsLayout);
            obj.createSpikeDetectorView(spikeDetecttionLabel, spikeDetecttionLayout);
            
            set(controlsLayout, 'Sizes', [100 100 100]);
        end
        
        function createCheckbox(obj, layout, channels)
            obj.channelChkBoxes = struct();
            
            for i = 1:length(channels)
                obj.channelChkBoxes.(channels{i}) = uicontrol(...,
                    'Parent', layout,...
                    'Style','checkbox',...
                    'String',sprintf('Channel %d',i),...
                    'Value',0,...
                    'callback',@(h, d)notify(obj, 'updateAmplifiers', util.EventData(channels{i}, get(h, 'Value'))),...
                    'Tag',channels{i});
            end
        end
        
        function createSpikeDetectorView(obj, labelLayout, controlLayout)
            uicontrol(...,
                'Parent', labelLayout,...
                'Style','text',...
                'String','Spike Threshold');
            obj.spikeDetectionEnabled = uicontrol(...,
                'Parent', labelLayout,...
                'Style','pushbutton',...
                'String','Enable', ...
                'Value', 1,...
                'callback',@(h, d)notify(obj, 'startSpikeDetection'));
            
            obj.thresholdTxt = uicontrol(...,
                'Parent', controlLayout,...
                'Style','Edit',...
                'String','00.000',...
                'callback',@(h, d)notify(obj, 'setThreshold'));
            obj.spikeDetectionDisabled = uicontrol(...,
                'Parent', controlLayout,...
                'Style','pushbutton',...
                'String','Disable', ...
                'Value', 0,...
                'callback',@(h, d)notify(obj, 'stopSpikeDetection'));
        end
    end
end

