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
            id =  obj.epoch.index;
            obj.verifyEqual(length(s.detect(obj.epoch, id)), expected);
        end
        
        function getSpikeIndices(obj)
            s = obj.spikeStatisctics;
            s.threshold = 40;
            start = obj.epoch.index;
            n = start + 10;
            for i = start:n
                s.detect(obj.epoch, i);
                obj.epoch.nextIndex;
            end
            expected = [6, 9, 12, 14, 7];
            actual = ones(1,5);
            for i = 1:5
                r = s.getSpikeIndices(i);
                actual(i) = length(r.spikes);
            end
           obj.verifyEqual(actual, expected);
        end
        
        function getPSTH(obj)
            s = obj.spikeStatisctics;
            s.threshold = 40;
            start = obj.epoch.index;
            n = start + 30;
            expected = [-0.4999 * ones(1,5); 0.5101 * ones(1,5)];
            for i = start:n
                s.detect(obj.epoch, i);
                obj.epoch.nextIndex;
            end
            actual = ones(2,5);
            for i = 1:5
              [x, ~] = s.getPSTH(i);
              actual(1,i) = min(x);
              actual(2,i) = max(x);
            end
            %validate range
            obj.verifyEqual(actual, expected); 
            %TODO to validate PSTHCount and smoothing window
        end
        
        % input details - {'pulseAmplitude', 490, 'scalingFactor', 2, 'numberOfIntensities', 5};
        function computeAvgResponseForTrails(obj)
            s = obj.spikeStatisctics;
            start = obj.epoch.index -1;
            s.computeAvgResponseForTrails(obj.epoch, start);
            obj.verifyEqual(length(s.avgResponse), 5);
            for i = 1:5
                 s.computeAvgResponseForTrails(obj.epoch, start + i -1);
                 obj.verifyEqual(s.avgResponse{i}.r, obj.epoch.response('ch1'));
            end
            r_cache = s.avgResponse;
            start = obj.epoch.index -1 + 5;
            for i = 1:5
                 s.computeAvgResponseForTrails(obj.epoch, start -1);
                 expected = mean([r_cache{i}.r , obj.epoch.response('ch1')], 2);
                 obj.verifyEqual(s.avgResponse{i}.r, expected);
            end
        end
    end
end

