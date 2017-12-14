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
        shutterTrigger              % Determines which digital port will be active for shutter TTL 
        stimX = 0                   % X co-ordinate of beam stimulation 
        stimY = 0                   % Y co-ordinate of beam stimulation
        stimZ = 0                   % Z co-ordinate of beam stimulation
    end

    properties (Hidden)
        sessionId
        controlShutter = true       % Control opening of shutter from symphony.
        cachedPhotonRate = -1       % set to invalid photon rate
        preRunPropertiesToLog = { ...
            'photonRate' ...
            'preTime' ...
            'stimTime' ...
            'tailTime' ...
            'ampHoldSignal' ...
            'sourceType' ...
            'stimX' ...
            'stimY' ...
            'stimZ' ...
            };
        postEpochLogging = {'cachedPhotonRate'}
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
                    p.defaultValue = {'SPS', 'PS'};  % SPS for Single-Photon Source; PS for Poisson sourse
                case {'photonRate'}
                    p.units = 'photons/flash';
                case {'shutterTrigger'}
                    p.defaultValue = {'port1', 'port2'};
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
            obj.sessionId = char(java.util.UUID.randomUUID);
            
            if obj.hasSinglePhotonSource()
                try
                    obj.setState('paused');
                    [~, responseJson] = obj.rigConfig.singlePhotonSourceClient.sendReceive(obj, SinglePhotonSourceClient.REQUEST_SET_PARAMETERS_ACTION);
                    obj.sendToLog(['REQUEST_SET_PARAMETERS_ACTION [' obj.sessionId '] ' responseJson]);
                catch e
                    obj.stop();
                    waitfor(errordlg(['An error occurred while running the protocol.' char(10) char(10) getReport(e, 'extended', 'hyperlinks', 'off')]));
                end
            end
            prepareRun@LabProtocol(obj);
        end
        
        function prepareEpoch(obj, epoch)
            
            amplifierMode = obj.rigConfig.multiClampMode(obj.amp);
            epoch.addParameter('amplifierMode', amplifierMode);
            
            if ~ isempty(obj.rigConfig.deviceWithName('Oscilloscope_Trigger'))
                epoch.addStimulus('Oscilloscope_Trigger', obj.ttlStimulus());
            end
            
            if obj.hasValidShutter()
                if strcmp(obj.shutterTrigger, 'port1')
                    epoch.addStimulus('Shutter_Trigger', obj.shutterStimulus());
                else 
                    epoch.addStimulus('Shutter_Trigger_Secondary', obj.shutterStimulus());
                end
            end
            % Get the observed photon rate 
            if obj.hasSinglePhotonSource() %% && mod(obj.numEpochsCompleted, 3) == 0 
                [response, responseJson] = obj.rigConfig.singlePhotonSourceClient.sendReceive(obj, SinglePhotonSourceClient.REQUEST_GET_PHOTON_RATE_ACTION);
                epoch.addParameter('REQUEST_GET_PHOTON_RATE_ACTION', responseJson);
                obj.cachedPhotonRate = response.observedPhotonRate;
            end
            epoch.addParameter('observedPhotonRate', obj.cachedPhotonRate);
            epoch.addParameter('sessionId', obj.sessionId);
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
            str = ['#' num2str(obj.numEpochsCompleted) ' observed photon rate ' num2str(obj.cachedPhotonRate) ]; %
        end

        function tf = hasSinglePhotonSource(obj)
            tf = isprop(obj.rigConfig, 'singlePhotonSourceClient');
        end    

        function tf = hasValidShutter(obj)
            tf = obj.controlShutter && ~ isempty(obj.rigConfig.deviceWithName('Shutter_Trigger')) && ~ isempty(obj.rigConfig.deviceWithName('Shutter_Trigger_Secondary'));
        end
    end
        
end

