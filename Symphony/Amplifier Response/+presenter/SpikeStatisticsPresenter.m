classdef SpikeStatisticsPresenter < handle
    %SPIKEPRESENTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        spikeStatisticsModel
        spikeStatiscticsView;
    end
    
    methods
        function obj = SpikeStatisticsPresenter(view, model)
            obj.spikeStatiscticsView = view;
            obj.spikeStatisticsModel = model;
        end
        
        function show(obj, status)
            obj.bind;
            m = obj.spikeStatisticsModel;
            v = obj.spikeStatiscticsView;
            channels = m.keys;
            statistics = m(channels{1});
            
            if statistics.enabled
                voltages = statistics.intensitiesToVoltages;
                v.showIntensity(voltages);
                v.show(status, channels);
            end
        end
        
        
        function bind(obj)
            v = obj.spikeStatiscticsView;
            addlistener(v, 'selectIntensity', @obj.selectIntensity);
        end
        
        function selectIntensity(obj, ~, eventData)
            m = obj.spikeStatisticsModel;
            index = m.activeIntensityIndex;
            
            if eventData
                index = [index, eventData];
            else
                index(index == eventData) = [];
            end
            m.activeIntensityIndex = unique(index);
        end
        
        function showPSTH(obj, channels)
            m = obj.spikeStatisticsModel;
            v = obj.spikeStatiscticsView;
            intensityIndex = m.activeIntensityIndex;
            
            for i = 1:length(channels)
                statistics = m(channel);
                if active && statistics.enabled
                    [x, y] = statistics.getPSTH(intensityIndex);
                    v.plotPSTH(channel, x, y);
                end
            end
        end
    end
    
end

