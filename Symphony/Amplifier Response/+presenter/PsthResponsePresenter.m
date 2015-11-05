classdef PsthResponsePresenter < Presenter
    
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
            addlistener(v, 'ShowPsthResponse', @obj.viewPsthResponse);
        end
        
        function onStopping(obj)
            obj.view.clearControlsLayout();
        end
    end
    
    methods
        
        function obj = PsthResponsePresenter(view, service)
            obj@Presenter(view);
            obj.spikeServices = service;
        end
        
        function viewPsthResponse(obj, ~, ~)
            import constants.*;
            legends = GraphingConstants.COLOR_SET.cell;
            
            v = obj.view;
            indices = v.getSelectedVoltageIndex();
            channel = v.getSelectedChannel();
            
            for i = 1:length(indices)
                s = obj.spikeServices(channel);
                if s.enabled
                    s.smoothingWindow = v.getSmoothingWindow();
                    [x, y] = s.getPSTH(indices(i));
                    v.plot(x, y, 'color', legends{indices(i)});
                end
            end
            v.resetGraph();
            v.renderGraph();
        end
    end
end

