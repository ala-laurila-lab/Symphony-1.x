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
            plotsKey = {obj.getChannels{:}};
            plotsValue = zeros(1,length(plotsKey));
            model.plotMap = containers.Map(plotsKey,plotsValue);
        end
        
        function updatePlots(obj, ~, ~, channelCheckBoxes, model)
            checkBox = obj.getValues(channelCheckBoxes);
            
            for i = 1:length(checkBox)
                model.plotMap(checkBox(i).Tag) = checkBox(i).Value;
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
            channels = {'ch1', 'ch2', 'ch3', 'ch4'};
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

