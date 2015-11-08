classdef AverageResponsePresenter < Presenter
    
    properties
        spikeServices
    end
    
    methods(Access = protected)
        
        function onGoing(obj)
            v = obj.view;
            channels = obj.spikeServices.keys;
            s = obj.spikeServices(channels{1});
            voltages = s.intensitiesToVoltages();
            v.setControlsLayout(voltages, channels);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'ShowAverageResponse', @obj.viewAverageResponse);
        end
        
        function onStopping(obj)
            v = obj.view;
            v.saveFigureHandlePosition();
            v.clearControlsLayout();
        end
    end
    
    methods
        
        function obj = AverageResponsePresenter(service, view)
            if nargin < 2
                view = views.AverageResponseView();
            end
            obj@Presenter(view);
            obj.spikeServices = service;
        end
        
        function viewAverageResponse(obj, ~, ~)
            import constants.*;
            legends = GraphingConstants.COLOR_SET.cell;
            
            v = obj.view;
            indices = v.getSelectedVoltageIndex();
            channel = v.getSelectedChannel();
            for i = 1:length(indices)
                s = obj.spikeServices(channel);
                [x, y] = s.getAvgResponse(indices(i));
                v.plot(x, y, 'color', legends{indices(i)});
            end
            v.resetGraph();
            v.renderGraph();
        end
    end
end

