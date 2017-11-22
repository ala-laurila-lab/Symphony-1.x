classdef SinglePhoton < LabProtocol
    
    % This class is used to define the stimuls parameter for single photon
    % source
    
    
    properties (Constant)
        identifier = 'petri.symphony-das.MultiPhoton'
        version = 1
        displayName = 'Single Photon'
    end
    
    properties
        amp
        preTime = 500
        stimTime = 500
        tailTime = 500
        ampHoldSignal = 0
        useTrigger = false
        sourceType = 'type' % SPS for Single-Photon Source; PS for Poisson sourse
        photonRate = 1 % photon rate per flash
        pulseWidth = 2 
        emergencySignal = 'none'
        numberOfEpochs = 5;
        action = 1; % 0 for setting the rate; 1 for stimulation
        
    end
    
    methods
        
        function p = parameterProperty(obj, parameterName)
            % Call the base method to create the property object.
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
            end
            
            if ~ p.units
                p.units = '';
            end
        end
        
        % Overridden Functions
        function prepareRig(obj)
            obj.applyAmpHoldSignal();
        end
        
        function prepareEpoch(obj, epoch)
            
            response = obj.rigConfig.singlePhotonSourceClient.sendReceive(obj);

            epoch.waitForTrigger = obj.useTrigger;
            amplifierMode = obj.rigConfig.multiClampMode(obj.amp);
            epoch.addParameter('amplifierMode', amplifierMode);
            epoch.addParameter('ndfCh1', obj.ndfCh1);
            epoch.addParameter('ndfCh2', obj.ndfCh2);
            
            if ~isempty(obj.rigConfig.deviceWithName('Oscilloscope_Trigger'))
                epoch.addStimulus('Oscilloscope_Trigger', obj.ttlStimulus());
            end
            
            % Call the base method.
            prepareEpoch@SymphonyProtocol(obj, epoch);
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
        
        function keepGoing = continueRun(obj)
            % Check the base class method to make sure the user hasn't paused or stopped the protocol.
            keepGoing = continueRun@SymphonyProtocol(obj);
            
            % Keep going until the requested number of averages have been completed.
            if keepGoing
                keepGoing = obj.numEpochsCompleted < obj.numberOfEpochs && ...
                    (obj.numEpochsCompleted < 1 || obj.numEpochsCompleted ~= obj.numberOfEpochs);
            end
        end
        
        function str = tostr(obj)
            str = 'TODO '; %
        end
        
        function  tf = isequal(obj, other)
            tf= isequal(class(obj), class(other)) && ...
                isequal(obj.preTime, other.preTime) && ...
                isequal(obj.stimTime, other.stimTime) && ...
                isequal(obj.tailTime, other.tailTime) && ...
                isequal(obj.ampMode, other.ampMode) && ...
                isequal(obj.ampHoldSignal, other.ampHoldSignal) && ...
                isequal(obj.useTrigger, other.useTrigger) && ...
                isequal(obj.sourceType, other.sourceType) && ...
                isequal(obj.photonRate, other.photonRate) && ...
                isequal(obj.pulseWidth, other.pulseWidth) && ...
                isequal(obj.emergencySignal, other.emergencySignal);
        end
    end
    
end

