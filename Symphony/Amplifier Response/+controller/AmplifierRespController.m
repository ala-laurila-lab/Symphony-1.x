classdef AmplifierRespController < handle
    %AMPRESPCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rigConfig
    end
    
    methods
        
        function obj = AmplifierRespController(rigConfig)
            obj.rigConfig = rigConfig;
        end
        
        function configurePlots(obj, model)
            plotsKey = obj.getChannels;
            plotsValue = model.initPlotMapValues(length(plotsKey));
            model.plotMap = containers.Map(plotsKey,plotsValue);
        end
        
        function updatePlots(obj, ~, ~, channelCheckBoxes, model)
            checkBox = obj.getValues(channelCheckBoxes, []);
            
            for i = 1:length(checkBox)
                tag = get(checkBox(i),'Tag');
                s= model.plotMap(tag);
                s.active = tag;
                model.plotMap(tag) = s;
            end
        end
        
        function autoScale(obj, hObj, ~, sliderX, sliderY, channelRadioBtns, model)
            
            model.autoScale = get(hObj, 'Value');
            set(sliderX, 'Enable', 'off');
            set(sliderY, 'Enable', 'off');
            obj.groupRadio(hObj, channelRadioBtns);
            
        end
        
        function selectScalingChannel(obj, hObj, ~, sliderX, sliderY, channelRadioBtns, model)
            
            if model.autoScale
                set(sliderX, 'Enable', 'on');
                set(sliderY, 'Enable', 'on');
            end
            obj.groupRadio(hObj, channelRadioBtns);
            model.autoScale = false;
        end
        
        function handleSliderX(~, hObj, eventData)
            disp('To do handle response');
        end
        
        function handleSliderY(~, hObj, eventData)
            disp('To do handle response');
        end
        
        
        function channels = getChannels(obj)
            channels = obj.rigConfig.multiClampDeviceNames;
        end
        
    end
    
    methods(Access = private)
        
        function groupRadio(obj, selected, buttons)
            filter = @(x) ~strcmp(x.Tag, get(selected, 'Tag'));
            nonSelectedChannels = obj.getValues(buttons, filter);
            arrayfun(@(ch) set(ch, 'Value', 0), nonSelectedChannels);
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

