classdef PsthRespPresenter < handle
    %SPIKEPRESENTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        app
        psthRespView
        psthRespModel
    end
    
    methods
        function obj = PsthRespPresenter(view, model, app)
            obj.psthRespView = view;
            obj.psthRespModel = model;
            obj.app = app;
        end
        
        function show(obj, status)
            channels = obj.app.keys;
            statistics = obj.app(channels{1});
            obj.bind;
            
            if statistics.enabled
                v = obj.psthRespView;
                m = obj.psthRespModel;
                voltages = statistics.intensitiesToVoltages;
                m.intensityIndex = zeros(1, length(voltages));
                v.clear;
                v.show(status, voltages, channels, m.colorset);
            end
        end
        
        function bind(obj)
            v = obj.psthRespView;
            addlistener(v, 'selectIntensity', @obj.selectIntensity);
            addlistener(v, 'psthResponse', @obj.showAllPSTH);
            addlistener(v, 'setSmoothingWindow', @obj.setSmoothingWindow);
            addlistener(v, 'Close', @obj.close);
        end
        
        function selectIntensity(obj, ~, e)
            m = obj.psthRespModel;
            m.intensityIndex(e.key) = e.value;
        end
        
        function setSmoothingWindow(obj, ~, e)
            m = obj.psthRespModel;
            m.smoothingWindow = str2double(e.value);  
        end
        
        function showAllPSTH(obj, ~, ~)
            channels = obj.app.keys;
            cellfun(@(channel) obj.showPSTH(channel), channels);
            obj.psthRespView.renderGraph;
        end
        
        function showPSTH(obj, channel)
            m = obj.psthRespModel;
            v = obj.psthRespView;
            indices = m.intensityIndex;
            indices = find(indices == 1);
            
            for i = 1:length(indices)
                statistics = obj.app(channel);
                statistics.smoothingWindow = m.smoothingWindow;
                if statistics.enabled
                    [x, y] = statistics.getPSTH(indices(i));
                    v.plotPSTH(channel, x, y, m.colorset{i});
                end
            end
        end
        
        function close(obj, ~, ~)
            v = obj.psthRespView;
            v.hide();
        end
    end
    
end

