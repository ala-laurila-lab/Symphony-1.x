% The steps for this equation are
% pulseAmlitude
% pulseAmlitude * scalingFactor
% pulseAmlitude * scalingFactor ^ 2
% pulseAmlitude * scalingFactor ^ 4
% pulseAmlitude * scalingFactor ^ 6
% ....
% Until the max limit is reached

classdef LEDFactorPulse < LabProtocol
    
    
    properties (Constant)
        identifier = 'petri.symphony-das.LEDFactorPulse'
        version = 1
        displayName = 'LED Factor Pulse'
    end
    
    
    properties
        amp
        StimulusLED = {'Ch1','Ch2','Ch3'}     % Note: To use a third channel add 'Ch3' to the object
        initialPulseAmplitude = 1000
        scalingFactor = 1
        preTime = 500
        stimTime = 500
        tailTime = 500
        numberOfIntensities = 1
        numberOfRepeats = 5
        interpulseInterval = 0
        interepochgrpInterval  = 0
        ampHoldSignal = 0
        %lightRange = {'pico','nano','micro','raw'}
    end
    
    
    properties (Hidden)
        pulseAmplitude
        power = 0;
        numberOfEpochs = 0;
        generator;
        units;
        preRunPropertiesToLog = { ...
            'StimulusLED' ...
            'preTime' ...
            'stimTime' ...
            'tailTime' ...
            'ampHoldSignal' ...
            };
        LEDBackground = 0;
        storedPulseAmplitudeAndBackground = {};
        epochCount = 0;
        finishAfterRepeat = false;
        epochsInSet = 0;
    end
    
    properties (Hidden, Constant)
        allowLogging = true;
    end
    
    methods
        
        function p = parameterProperty(obj, parameterName)
            % Call the base method to create the property object.
            %p = parameterProperty@SymphonyProtocol(obj, parameterName);
            p = parameterProperty@LabProtocol(obj, parameterName);
            % Return properties for the specified parameter (see ParameterProperty class).
            switch parameterName
                case 'amp'
                    % Prefer assigning default values in the property block above.
                    % However if a default value cannot be defined as a constant or expression, it must be defined here.
                    p.defaultValue = obj.rigConfig.ampDeviceNames();
                case {'preTime', 'stimTime', 'tailTime'}
                    p.units = 'ms';
                case {'ampHoldSignal'}
                    p.units = obj.rigConfig.getAmpUnits(obj.amp);
                case {'initialPulseAmplitude'}
                    p.units = 'mV';
            end
            
            if ~p.units
                p.units = '';
            end
        end
        
        %% Overridden Functions
        function prepareRig(obj)
            obj.applyAmpHoldSignal();
            obj.isOverMaxAmplitude();
        end
        
        function prepareRun(obj)
            % Call the base method.
            prepareRun@LabProtocol(obj);
            obj.generator = PulseFactorGenerator(obj.preTime, obj.stimTime, obj.tailTime, obj.sampleRate);
            obj.resetParameters();
            obj.numberOfEpochs = obj.numberOfIntensities * obj.numberOfRepeats;
            obj.finishAfterRepeat = false;
            obj.epochsInSet = 0;
        end
        
        function prepareEpoch(obj, epoch)
            % Call the base method.
            prepareEpoch@SymphonyProtocol(obj, epoch);
            amplifierMode = obj.rigConfig.multiClampMode(obj.amp);
            epoch.addParameter('amplifierMode', amplifierMode);
            % Add the amp pulse stimulus to the epoch.
            epoch.addStimulus(obj.StimulusLED, obj.ledStimulus(obj.StimulusLED));
            epoch.addParameter('pulseAmplitude', obj.pulseAmplitude + obj.LEDBackground);%DT
            epoch.addParameter('backgroundAmplitude', obj.LEDBackground);%DT
            
            if ~isempty(obj.rigConfig.deviceWithName('Oscilloscope_Trigger'))
                epoch.addStimulus('Oscilloscope_Trigger', obj.ttlStimulus());
            end
        end
        
        function queueEpoch(obj, epoch)
            % Call the base method to queue the actual epoch.
            queueEpoch@SymphonyProtocol(obj, epoch);
            
            % Queue an inter-pulse interval after queuing the epoch.
            if obj.interepochgrpInterval > 0 && mod(obj.numEpochsQueued, obj.numberOfIntensities) == 0
                obj.queueInterval(obj.interepochgrpInterval);
            elseif obj.interpulseInterval > 0
                obj.queueInterval(obj.interpulseInterval);
            end
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@LabProtocol(obj, epoch);
        end
        
        function keepQueuing = continueQueuing(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepQueuing = continueQueuing@SymphonyProtocol(obj);
            
            % Keep queuing until the requested number of averages have been queued.
            if keepQueuing
                keepQueuing = obj.numEpochsQueued < obj.numberOfEpochs;
                if ~keepQueuing
                    obj.numberOfEpochs = obj.numEpochsQueued;
                end
                
            end
        end
        
        
        function keepGoing = continueRun(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepGoing = continueRun@SymphonyProtocol(obj);
            
            % Keep going until the requested number of averages have been completed.
            if keepGoing
                keepGoing = obj.numEpochsCompleted < obj.numberOfEpochs && ...
                    (obj.numEpochsCompleted < 1 || obj.numEpochsCompleted ~= obj.numberOfEpochs && ~(obj.epochsInSet == 0 && obj.finishAfterRepeat));
            end
        end
        
        %% Stimulous Functions
        function stim = ledStimulus(obj, device)
            if obj.numEpochsQueued ~= 0 && mod(obj.numEpochsQueued, obj.numberOfIntensities) == 0
                obj.power = 0;
                obj.pulseAmplitude = obj.initialPulseAmplitude;
            end
            
            if exist('device','var')
                obj.LEDBackground = obj.getDeviceBackground(device);
            else
                obj.LEDBackground = 0;
            end
            
            obj.epochCount = obj.epochCount + 1;
            obj.pulseAmplitude = obj.initialPulseAmplitude * (obj.scalingFactor)^obj.power;
            obj.storedPulseAmplitudeAndBackground{obj.epochCount} = obj.pulseAmplitude + obj.LEDBackground;
            obj.power = obj.power + 1;
            obj.generator.units = 'mV';
            obj.generator.pulseAmplitude = obj.pulseAmplitude;
            obj.generator.background = obj.LEDBackground;
            stim = obj.generator.generate();
        end
        
        function stimuli = sampleStimuli(obj)
            % Return a sample stimulus for display in the edit parameters window.
            try
                obj.generator = PulseFactorGenerator(obj.preTime, obj.stimTime, obj.tailTime, obj.sampleRate);
                obj.resetParameters();
                stimuli = cell(obj.numberOfIntensities, 1);
                for i=1:obj.numberOfIntensities
                    stimuli{i} = obj.ledStimulus();
                end
            catch
            end
        end
        
        function stim = ttlStimulus(obj)
            % Construct a repeating pulse stimulus generator.
            p = PulseGenerator();
            
            p.preTime = 0;
            p.stimTime = 1;
            p.tailTime = obj.preTime + obj.stimTime + obj.tailTime - 1;
            p.amplitude = 1;
            p.mean = 0;
            p.sampleRate = obj.sampleRate;
            p.units = Symphony.Core.Measurement.UNITLESS;
            
            % Generate the stimulus object.
            stim = p.generate();
        end
        
        
        %% utility Functions
        function resetParameters(obj)
            obj.pulseAmplitude = obj.initialPulseAmplitude;
            obj.power = 0;
            obj.numEpochsQueued = 0;
            obj.storedPulseAmplitudeAndBackground = {};
            obj.epochCount = 0;
            obj.finishAfterRepeat = false;
            obj.epochsInSet = 0;
        end
        
        function isOverMaxAmplitude(obj)
            if	(obj.initialPulseAmplitude*(obj.scalingFactor^(obj.numberOfIntensities-1)) + obj.LEDBackground) > 10000;
                error('StimulusLED:CONTROLLER:ERROR', 'The max value for the protocol has to be less then 10,000mV')
            end
        end
        
        function str = tostr(obj)
            stimulsAmplitude = obj.storedPulseAmplitudeAndBackground{obj.numEpochsCompleted};
            str = sprintf('Stimulus amplitude = %d mv, Intensity = %d (initial amplitude) * %d, %d repetitions,  Holding signal = %d',...
                stimulsAmplitude, obj.initialPulseAmplitude, obj.numberOfIntensities, obj.numberOfRepeats, obj.ampHoldSignal );
        end
    end
    
end

