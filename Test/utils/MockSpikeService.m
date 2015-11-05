classdef MockSpikeService < handle
    
    properties
        noise = randn(10000,1);
        rate = 10000
        smoothingWindow
        enabled = 1
    end
    
    methods
        function r = intensitiesToVoltages(~)
            r= [100, 200, 300, 400, 500];
        end
        function[x, y] = getAvgResponse(obj, idx)
            y = obj.noise;
            x = (1:numel(y))/obj.rate;
        end
        
        function[x, y] = getPSTH(obj, idx)
            y = obj.noise;
            x = (1:numel(y))/obj.rate;
        end
    end
    methods(Static)
        function o = createMockObj()
            o = containers.Map({'amp1', 'amp2'}, {MockSpikeService(), MockSpikeService()});
        end
        
    end
    
end
% usage 
% p = presenter.AverageResponsePresenter(view.AverageResponseView(), MockSpikeService.createMockObj()); p.go();
% p = presenter.PsthResponsePresenter(view.PsthResponseView(), MockSpikeService.createMockObj()); p.go();
