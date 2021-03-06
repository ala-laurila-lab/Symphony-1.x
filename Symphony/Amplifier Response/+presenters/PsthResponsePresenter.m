classdef PsthResponsePresenter < Presenter
    
    properties
        spikeServices
    end
    
    methods(Access = protected)
        
        function onGoing(obj)
            v = obj.view;
            channels = obj.spikeServices.keys;
            s = obj.spikeServices(channels{1});
            voltages = s.getGroupByLabel();
            v.setControlsLayout(voltages, channels);
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'ShowPsthResponse', @obj.viewPsthResponse);
            obj.addListener(v, 'ShowAllPsthResponse', @obj.viewAllPsthResponse);
        end
        
        function onGo(obj)
            obj.viewAllPsthResponse();
        end
        
        function onStopping(obj)
            v = obj.view;
            v.saveFigureHandlePosition();
            v.clearControlsLayout();
        end
    end
    
    methods
        
        function obj = PsthResponsePresenter(service, view)
            if nargin < 2
                view = views.PsthResponseView();
            end
            obj@Presenter(view);
            obj.spikeServices = service;
        end
        
        function viewPsthResponse(obj, ~, ~)
            import constants.*;
            legends = GraphingConstants.COLOR_SET.cell;
            
            v = obj.view;
            idx = v.getSelectedVoltageIndex();
            channel = v.getSelectedChannel();
            
            for i = 1:length(idx)
                s = obj.spikeServices(channel);
                if s.enabled
                    s.smoothingWindow = v.getSmoothingWindow();
                    [x, y] = s.getPSTH(idx(i));
                    v.plot(x, y, 'color', legends{idx(i)}.getValue());
                end
            end
            v.resetGraph();
            v.renderGraph();
        end
        
        function viewAllPsthResponse(obj, ~, ~)
            v = obj.view;
            tf = v.hasAllVoltagesChecked();
            if ~tf
                obj.view.clearGraph();
                obj.view.resetGraph();
            end
            v.setAllVoltages(tf);
            obj.viewPsthResponse();
        end
    end
end

