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
            checkBox = obj.getValues(channelCheckBoxes);
            
            for i = 1:length(checkBox)
                s= model.plotMap(checkBox(i).Tag);
                s.active = checkBox(i).Value;
                model.plotMap(checkBox(i).Tag) = s;
            end
        end
        
        function handleSliderX(~, hObj, eventData)
            disp('To do handle response');
        end
        
        function handleSliderY(~, hObj, eventData)
            disp('To do handle response');
        end
        
        function selectScalingChannel(obj, hObj, ~, channelRadioBtns)
            arr = obj.getValues(channelRadioBtns);
            nonSelectedChannels = arr(~ismember(arr,hObj));
            
            for i = 1:length(nonSelectedChannels)
                nonSelectedChannels(i).Value = 0;
            end
        end
        
        function channels = getChannels(obj)
            channels = obj.rigConfig.multiClampDeviceNames;
        end
        
        function ch = getActiveCheckBox(~, channels)
            ch = {};
            
            for i = 1:length(channels)
                if(channels(i).Value)
                    ch = {ch, channels(i).Tag};
                end
            end
            ch(~cellfun('isempty',ch));
        end
        
        function v = getValues(~, s)
            f = fieldnames(s);
            v = [];
            
            for i = 1:length(f)
                v = [v get(s.(f{i}))];
            end
        end
    end
end

