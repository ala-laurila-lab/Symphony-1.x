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
            obj.bind;
            v = obj.psthRespView;
            m = obj.psthRespModel;
            channels = obj.app.keys;
            statistics = obj.app(channels{1});
            
            if statistics.enabled
                voltages = statistics.intensitiesToVoltages;
                m.intensityIndex = zeros(1, length(voltages));
                v.showIntensity(voltages);
            end
            v.show(status, channels);
        end
        
        function bind(obj)
            v = obj.psthRespView;
            addlistener(v, 'selectIntensity', @obj.selectIntensity);
            addlistener(v, 'psthResponse', @obj.showAllPSTH);
        end
        
        function selectIntensity(obj, ~, e)
            m = obj.psthRespModel;
            m.intensityIndex(e.key) = e.value;
        end
        
        function showAllPSTH(obj, ~, ~)
             channels = obj.app.keys;
             cellfun(@(channel) obj.showPSTH(channel), channels)
        end
        
        function showPSTH(obj, channel)
             m = obj.psthRespModel;
             v = obj.psthRespView;
            indices = m.intensityIndex;
            indices = indices(indices == 1);
            
            for i = 1:length(indices)
                statistics = obj.app(channel);
                if statistics.enabled
                    [x, y] = statistics.getPSTH(indices(i));
                    v.plotPSTH(channel, x, y);
                end
            end
        end
    end
    
end

