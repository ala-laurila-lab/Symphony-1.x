classdef PulseFactorGenerator < StimulusGenerator
    %PULSEFACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        identifier = 'petri.symphony-das.PulseFactorGenerator'
        version = 1
    end
    
    properties
        pulseAmplitude
        units
        background
    end
    
    properties (Access = private)
        prePts     % Leading duration (ms)
        stimPts    % Ramp duration (ms)
        tailPts    % Trailing duration (ms)
        sampleRate
    end
    
    methods
        function obj = PulseFactorGenerator(preTime, stimTime, tailTime, sampleRate)         
            obj = obj@StimulusGenerator(struct());
            
            obj.sampleRate = sampleRate;
            timeToPts = @(t)(round(t / 1e3 * obj.sampleRate));
            obj.prePts = timeToPts(preTime);
            obj.stimPts = timeToPts(stimTime);
            obj.tailPts = timeToPts(tailTime);
        end
        
        function set.units(obj, value)
            obj.units = value;
        end

        function set.pulseAmplitude(obj, value)
            obj.pulseAmplitude = value;
        end
    end
    
    methods (Access = protected)
        function stim = generateStimulus(obj)
            import Symphony.Core.*;

            data = ones(1, obj.prePts + obj.stimPts + obj.tailPts) * obj.background;
            data(obj.prePts + 1:obj.prePts + obj.stimPts) = obj.pulseAmplitude + obj.background;

            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);

            
            stim = RenderedStimulus(obj.identifier, obj.stimulusParameters, output);
        end
    end
    
end

