classdef TestSpikeStatistics < matlab.unittest.TestCase
    %TESTSPIKESTATISCTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        spikeStatisctics
        epoch
    end
    
    methods (TestClassSetup)
        
        function classSetup(obj)
            obj.epoch = MockEpoch;
            obj.spikeStatisctics = service.SpikeStatistics('ch1');
        end
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            obj.epoch.index = 21;
            obj.spikeStatisctics.init(obj.epoch)
        end
    end
    
    methods (TestMethodTeardown)
        
        function methodTeardown(obj)
        end
    end
    
    methods (Test)
        
        function selectIntensity(obj)
            %{'pulseAmplitude', 490, 'scalingFactor', 2, 'numberOfIntensities', 5};
            s = obj.spikeStatisctics;
            expected = [490, 980, 1960, 3920, 7840];
            obj.verifyEqual(s.intensitiesToVoltages, expected);
        end
        
        function getSampleSizePerBin(obj)
            %{sampling rate = 10,000 Hz, binwidth = 10}
            s = obj.spikeStatisctics;
            expected = 100;
            obj.verifyEqual(s.getSampleSizePerBin, expected);
        end
        
        function detectSpikes(obj)
            s = obj.spikeStatisctics;
            s.threshold = 40;
            expected = 5;
            obj.verifyEqual(length(s.detect(obj.epoch, 1)), expected);
        end
        
        function getSpikeIndices(obj)
            s = obj.spikeStatisctics;
            s.threshold = 40;
            for i = 1:10
                s.detect(obj.epoch, i);
                obj.epoch.nextIndex;
            end
            expected = [5, 9, 12, 14, 7];
            actual = ones(1,5);
            for i = 1:5
                r = s.getSpikeIndices(i);
                actual(i) = length(r.spikes);
            end
           obj.verifyEqual(actual, expected);
        end
    end
end

