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
            plotsValue = model.init(plotsKey);
            model.plotMap = containers.Map(plotsKey,plotsValue);
        end
        
        function updatePlots(obj, ~, ~, channelCheckBoxes, model)
            checkBox = obj.getValues(channelCheckBoxes, []);
            
            for i = 1:length(checkBox)
                ch = get(checkBox(i),'Tag');
                model.set(ch, 'active', get(checkBox(i), 'value'));
            end
        end
        
        function autoScale(obj, hObj, ~, shiftY, scaleY, channelRadioBtns, model)
            
            model.autoScale = get(hObj, 'Value');
            set(shiftY, 'Enable', 'off');
            set(scaleY, 'Enable', 'off');
            obj.groupRadio(hObj, channelRadioBtns);
            
        end
        
        function selectScalingChannel(obj, hObj, ~, shiftY, scaleY, channelRadioBtns, model)
            
            if model.autoScale
                set(shiftY, 'Enable', 'on');
                set(scaleY, 'Enable', 'on');
            end
            obj.groupRadio(hObj, channelRadioBtns);
            model.autoScale = false;
            set(shiftY, 'value', model.plotMap(get(hObj, 'Tag')).shift);
            set(scaleY, 'value', model.plotMap(get(hObj, 'Tag')).scale);
        end
        
        function shiftYAxis(obj, hObj, ~, channelRadioBtns, model)
            ch = obj.getActiveRadio(channelRadioBtns);
            model.set(ch, 'shift', get(hObj, 'value'));
        end
        
        function scaleYAxis(obj, hObj, ~, channelRadioBtns, model)
            ch = obj.getActiveRadio(channelRadioBtns);
            model.set(ch, 'scale', get(hObj, 'value'));
        end
        
        function setThreshold(obj, hObj, ~, channelRadioBtns, model)
            ch = obj.getActiveRadio(channelRadioBtns);
            spd = model.spikeDetectorMap(ch);
            spd.threshold = str2double(get(hObj, 'String'));
            spd.direction = sign(spd.threshold);
        end
        
        function enableSpikeDetection(obj, hObj, ~, channelRadioBtns, threshold, model)
             ch = obj.getActiveRadio(channelRadioBtns);
             spd = model.spikeDetectorMap(ch);
             spd.threshold = str2double(get(threshold, 'String'));
             spd.direction = sign(spd.threshold);
             spd.enabled = true;
        end
        
        function channels = getChannels(obj)
            channels = obj.rigConfig.multiClampDeviceNames;
        end
        
    end
    
    methods(Access = private)
        
        function channel = getActiveRadio(obj, buttons)
            activeRadioFilter = @(x) x.Value == 1;
            components = obj.getValues(buttons, activeRadioFilter);
            channel = get(components, 'Tag');
        end
        
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

