classdef SinglePhoton < LabProtocol
    
    % This class is used to define the stimuls parameter for single photon
    % source
    
    
    properties (Constant)
        identifier = 'petri.symphony-das.SinglePhoton'
        displayName = 'Single Photon'
        version = 1
    end
    
    properties
        amp
        ampHoldSignal = 0
        preTime = 500               % (ms)             
        stimTime = 500              % (ms)
        tailTime = 500              % (ms)
        numberOfEpochs = 5;
        sourceType                  % SPS for Single-Photon Source; PS for Poisson source
        photonRate = 1              % photon rate per flash
    end

    properties (Hidden)
        sessionId
        controlShutter = true       % Control opening of shutter from symphony.
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
                case {'sourceType'}
                    p.defaultValue = {'SPS', 'PS'}  % SPS for Single-Photon Source; PS for Poisson sourse
                case {'photonRate'}
                    p.units = 'rate/flash'
            end
            
            if ~ p.units
                p.units = '';
            end
        end
        
        % Overridden Functions
        function prepareRig(obj)
            obj.applyAmpHoldSignal();
        end
        
        function prepareRun(obj)
            obj.sessionId = matlab.lang.makeValidName(datestr(datetime));
            prepareRun@LabProtocol(obj);
        end
        
        function prepareEpoch(obj, epoch)
            
            if obj.hasSinglePhotonSource()
                [response, responseJson] = obj.rigConfig.singlePhotonSourceClient.sendReceive(obj, SinglePhotonSourceClient.REQUEST_STIMULATION_ACTION);
                epoch.addParameter('REQUEST_STIMULATION_ACTION', responseJson);
            end

            amplifierMode = obj.rigConfig.multiClampMode(obj.amp);
            epoch.addParameter('amplifierMode', amplifierMode);
            
            if ~ isempty(obj.rigConfig.deviceWithName('Oscilloscope_Trigger'))
                epoch.addStimulus('Oscilloscope_Trigger', obj.ttlStimulus());
            end
            
            if ~ isempty(obj.rigConfig.deviceWithName('Shutter_Trigger')) && obj.controlShutter
                epoch.addStimulus('Shutter_Trigger', obj.shutterStimulus());
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

        function stim = shutterStimulus(obj)
            % Construct a repeating pulse stimulus generator.
            p = PulseGenerator();
            
            p.preTime = obj.preTime;
            p.stimTime = obj.stimTime;
            p.tailTime = obj.tailTime;
            p.amplitude = 1;
            p.mean = 0;
            p.sampleRate = obj.sampleRate;
            p.units = Symphony.Core.Measurement.UNITLESS;
            
            % Generate the stimulus object.
            stim = p.generate();
        end
        
        function completeEpoch(obj, epoch)
            
            if obj.hasSinglePhotonSource()
                [response, responseJson] = obj.rigConfig.singlePhotonSourceClient.sendReceive(obj, SinglePhotonSourceClient.REQUEST_PHOTON_RATE_ACTION);
                epoch.addParameter('REQUEST_PHOTON_RATE_ACTION', responseJson);
                epoch.addParameter('observedPhotonRate', response.observedPhotonRate);
            end
            epoch.addParameter('sessionId', obj.sessionId);
            completeEpoch@LabProtocol(obj, epoch);
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
            tf = isequal(class(obj), class(other)) && ...
                isequal(obj.preTime, other.preTime) && ...
                isequal(obj.stimTime, other.stimTime) && ...
                isequal(obj.tailTime, other.tailTime) && ...
                isequal(obj.ampMode, other.ampMode) && ...
                isequal(obj.ampHoldSignal, other.ampHoldSignal) && ...
                isequal(obj.sourceType, other.sourceType) && ...
                isequal(obj.photonRate, other.photonRate);
        end

        function tf = hasSinglePhotonSource(obj)
            tf = isprop(obj.rigConfig, 'singlePhotonSourceClient');
        end    
    end
        
end

