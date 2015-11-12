classdef MockFactory < handle
    
    properties
        noise = randn(10000,1)
    end
    
    methods
        function o = getSpikeServiceObject(obj, ch)
            o = Mock(service.SpikeStatistics(ch));
            o.when.intensitiesToVoltages().thenReturn([100, 200, 300, 400, 500, 600, 700, 800, 900, 100, 1000]);
            x = (1:numel(obj.noise))/10000; y = obj.noise;
            o.when.getAvgResponse(Any(?double)).thenReturn(x, y);
            o.mockedObj.enabled = 1;
            o.mockedObj.smoothingWindow = 0;
            o.when.getPSTH(Any(?double)).thenReturn(x, y);
        end
        
        function o = getSpikeServices(obj)
            o = containers.Map({'amp1', 'amp2'}, {obj.getSpikeServiceObject('amp1'), obj.getSpikeServiceObject('amp2')});
        end
        
        function o = getLEDLabProtocol(~)
            o = Mock(LEDFactorPulse,  'tolerant');
            o.mockedObj.numEpochsCompleted = 1;
            o.mockedObj.numberOfEpochs = 5;
            o.when.tostr().thenReturn('Stimulus amplitude = 500 mv, Intensity = 500 (initial amplitude) * 5, 15 repetitions,  Holding signal = -30');
        end
    end
    
    methods(Static)
        function o = getInstance()
            persistent  obj;
            if isempty(obj) 
                obj = MockFactory();
            end
            o = obj;
        end
    end
end

% usage 
% p = presenters.AverageResponsePresenter(MockFactory.getInstance().getSpikeServices()); p.go();
% p = presenters.PsthResponsePresenter(MockFactory.getInstance().getSpikeServices()); p.go(); 