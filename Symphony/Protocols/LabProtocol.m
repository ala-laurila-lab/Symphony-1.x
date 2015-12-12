classdef LabProtocol < SymphonyProtocol
    %LABPROTOCOL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden)
        notepad = []
        SolutionController = []
        GraphingPrePoints = []
        GraphingAmplifierResponses = []
        SymphRigSwitches = []
        SolutionControllerStatusString
        rigSwitchNames = {}
        graphing = true
        deviceBackgrounds = {}
        amplifierResponses = []
        ndfConfiguration = []
        motorizedWheelConfig;
    end
    
    properties (Constant, Hidden)
        timeString = 'HH:MM:SS-dd/mm/yy';
        logTab = '      ';
    end
    
    properties
        ampMode
        fixedNdfs
        motorizedNdf
    end
    
    methods
        %% Overridden Functions
        function p = parameterProperty(obj, parameterName)
            % Call the base method to create the property object.
            p = parameterProperty@SymphonyProtocol(obj, parameterName);
            
            % Return properties for the specified parameter (see ParameterProperty class).
            switch parameterName
                case 'ampMode'
                    p.defaultValue ={'Cell attached','Whole cell'};
                case 'motorizedNdf'
                    motorizedWheels = @(config) config.active == true && config.motorized == true;
                    config = FilterWheelConfig.listByRigName(obj.rigConfig.RIG_NAME, motorizedWheels);
                    if ~isempty(config)
                        obj.motorizedWheelConfig = config(1);
                        p.defaultValue = cellfun(@(k) strcat(config(1).rigName, k ), config(1).ndfContainer.keys, 'UniformOutput', false);
                    end
            end
            
            if ~p.units
                p.units = '';
            end
        end
        function obj = init(obj, rigConfig)
            init@SymphonyProtocol(obj, rigConfig);
            obj.openModules();
            
            if obj.rigConfig.isRigSwitch()
                obj.SymphRigSwitches = SymphonyRigSwitches(obj, rigConfig, obj.symphonyUI);
            end
            
            if ~isempty(obj.SymphRigSwitches)
                obj.SymphRigSwitches.checkStatus();
            end
        end
        
        function ndfs = get.fixedNdfs(obj)
            manualWheels = @(config) config.active == true && config.motorized == false;
            config = FilterWheelConfig.listByRigName(obj.rigConfig.RIG_NAME, manualWheels);
            
            ndfs = [];
            for i = 1:numel(config)
                wheelObj = obj.rigConfig.filterWheels(char(config(i)));
                ndfs = [ndfs, wheelObj.getNDFIdentifier()];
            end
            ndfs = strjoin(ndfs,',');
        end
        
        function obj = set.fixedNdfs(obj, value)
            if isempty(value) || sum(isnan(value))
                return
            end
            ndfIds = strsplit(value, ',');
            ndfNames = cellfun(@(ndf) ndf(2:end), ndfIds, 'UniformOutput', false);
            manualWheels = @(config) config.active == true && config.motorized == false;
            configs = FilterWheelConfig.listByRigName(obj.rigConfig.RIG_NAME, manualWheels);
            
            for i = 1:numel(configs)
                 key = char(configs(i));
                 ndfName = ndfNames(isKey(configs(i).ndfContainer, ndfNames));
                 if ~ isempty(ndfName)
                    wheelObj = obj.rigConfig.filterWheels(key);   
                    wheelObj.setNDF(ndfName);
                 end
                 
                 if ~ isempty(obj.ndfConfiguration)
                    obj.ndfConfiguration.updateCurrentNdfText(key);
                end
            end
        end
        
        function setMotorizedNdf(obj)
            if isnan(obj.motorizedNdf)
                return;
            end
            config = char(obj.motorizedWheelConfig);
            ndfValue = obj.motorizedNdf(2 : end);
            wheelObj = obj.rigConfig.filterWheels(config);
            wheelObj.setNDF(ndfValue);

            if ~ isempty(obj.ndfConfiguration)
                obj.ndfConfiguration.updateCurrentNdfText(char(config));
            end
        end
        
        
        function prepareRun(obj)
            prepareRun@SymphonyProtocol(obj);
            obj.setMotorizedNdf();
            
            obj.sendToLog('');
            
            if ~isempty(obj.GraphingPrePoints) && obj.graphing
                obj.GraphingPrePoints.clearFigure();
            end
            
            if ~isempty(obj.GraphingAmplifierResponses) && obj.graphing
                obj.GraphingAmplifierResponses.clearFigure();
            end
            
            if ~isempty(obj.SymphRigSwitches)
                obj.SymphRigSwitches.checkStatus();
            end
            
            if obj.loggingIsValid
                formatSpec = '%s%s';
                s = sprintf(formatSpec, obj.displayName,obj.logTab);
                
                if isprop(obj, 'preRunPropertiesToLog')
                    s = obj.logProperties('preRunPropertiesToLog', s);
                end
                
                mode = '';
                
                if(obj.rigConfig.isMultiClampDevice(obj.amp))
                    multiclampDev = obj.rigConfig.multiClampDeviceNames();
                    
                    for d=1:length(multiclampDev)
                        mode = [mode multiclampDev{d} '-' obj.rigConfig.getAmpMode(multiclampDev{d}) obj.logTab ];
                    end
                    formatSpec = '%s%s%s';
                    s = sprintf(formatSpec, s, obj.logTab, mode);
                else
                    mode = obj.rigConfig.getAmpMode(obj.amp);
                    formatSpec = '%s%s%s-%s';
                    s = sprintf(formatSpec, s, obj.logTab, obj.amp, char(mode));
                end
                
                
                
                fieldNames = fieldnames(obj.deviceBackgrounds);
                for d = 1:numel(fieldNames)
                    formatSpec = '%s%s%s:%s';
                    s = sprintf(formatSpec, s,obj.logTab, fieldNames{d}, obj.deviceBackgrounds.(fieldNames{d}));
                end
                
                if ~isempty(obj.SolutionController)
                    obj.SolutionControllerStatusString = '';
                    status = obj.SolutionController.getStatus();
                    for v = 2:(length(status{1}))
                        obj.SolutionControllerStatusString = sprintf('%s %d', char(obj.SolutionControllerStatusString), str2double(status{1}{v}));
                    end
                    
                    formatSpec = '%s%sSolution Controller:%s%s';
                    s = sprintf(formatSpec, s,obj.logTab, obj.SolutionControllerStatusString, obj.logTab);
                end
                
                obj.sendToLog(s);
            end
        end
        
        function prepareEpoch(obj, epoch)
            prepareEpoch@SymphonyProtocol(obj, epoch);
        end
        
        function completeEpoch(obj, epoch)
            completeEpoch@SymphonyProtocol(obj, epoch);
            %epoch.addParameter('numberOfEpochsCompleted', obj.numEpochsCompleted);%DT
          
            if ~isempty(obj.SolutionController)
                epoch.addParameter('SolutionController', obj.SolutionControllerStatusString);
            end
            
            if isprop(obj, 'pulseAmplitude') && isprop(obj, 'storedPulseAmplitudeAndBackground')
                amplitude = obj.storedPulseAmplitudeAndBackground{obj.numEpochsCompleted};
                epoch.addParameter('StimAmp', amplitude);
            end
            
            if isprop(obj, 'epochsInSet') && isprop(obj, 'numberOfIntensities')
                obj.epochsInSet = obj.epochsInSet + 1;
                
                if obj.epochsInSet == obj.numberOfIntensities
                    obj.epochsInSet = 0;
                end
            end
            
            if obj.rigConfig.isDevice('HeatController')%DT
                temp = obj.recordSolutionTemp(epoch);
                epoch.addParameter('Temp', temp);
            end
            
            if obj.loggingIsValid
                formatSpec = '%u%s%u:%u:%u';
                s = sprintf(formatSpec, ...
                    obj.numEpochsCompleted, ...
                    obj.logTab, ...
                    epoch.startTime.Item2.Hour, ...
                    epoch.startTime.Item2.Minute, ...
                    epoch.startTime.Item2.Second);
                
                if obj.rigConfig.isDevice('Optometer') && isprop(obj, 'lightRange')
                    formatSpec = '%s%sOptometer: %s';
                    optometer = obj.recordLEDCalibration(epoch, obj.lightRange);
                    s = sprintf(formatSpec, s, obj.logTab, optometer);
                    epoch.addParameter('Optometer', optometer);
                end
                
                if ~isempty(amplitude)
                    formatSpec = '%s%sStimAmp:%gmV';
                    s = sprintf(formatSpec, s, obj.logTab, amplitude);
                end
                
                if obj.rigConfig.isDevice('HeatController')
                    formatSpec = '%s%sTemp:%gC';
                    %temp = obj.recordSolutionTemp(epoch);
                    s = sprintf(formatSpec, s, obj.logTab, temp);
                    %epoch.addParameter('Temp', temp + 'C');
                end
                
                if isprop(obj, 'postEpochLogging')
                    s = obj.logProperties('postEpochLogging', s);
                end
                
                obj.sendToLog(s);
            end
            
            if ~isempty(obj.GraphingPrePoints) && obj.graphing
                obj.GraphingPrePoints.handleEpoch(epoch);
            end
            
            if ~isempty(obj.GraphingAmplifierResponses) && obj.graphing
                obj.GraphingAmplifierResponses.handleEpoch(epoch);
            end
            
            if ~isempty(obj.SymphRigSwitches)
                if isempty(obj.rigSwitchNames)
                    obj.rigSwitchNames = obj.rigConfig.getRigSwitcheNames();
                end
                
                for s = 1:numel(obj.rigSwitchNames)
                    obj.SymphRigSwitches.switchesChanged(epoch.response(obj.rigSwitchNames{s}),s);
                end
            end
            
            if ~isempty(obj.amplifierResponses)
                obj.amplifierResponses.handleEpoch(epoch);
            end
        end
        
        function completeRun(obj)
            completeRun@SymphonyProtocol(obj)
            s = sprintf('\n');
            % Log LED channel information
            if obj.loggingIsValid
                fieldNames = fieldnames(obj.deviceBackgrounds);
                channelNames = fieldNames(strncmp('Ch',fieldNames,2));
                for d = 1:numel(channelNames)
                    formatSpec = '%sLED %s : %s%s';
                    s = sprintf(formatSpec, s, channelNames{d}, obj.deviceBackgrounds.(channelNames{d}), obj.logTab);
                end
                obj.sendToLog(s);
                obj.sendToLog(sprintf('\n'));
                obj.notepad.saveFcn();
            end
        end
        
        %% Module Functions
        function openModules(obj)
            for m = 1:numel(obj.symphonyUI.modules)
                module = obj.symphonyUI.modules{m};
                obj.moduleRegister(module.displayName,module);
            end
        end
        
        function moduleRegister(obj, displayName, module)
            if strcmp(displayName, 'Notepad') && isempty(obj.notepad)
                obj.notepad = module;
            end
            
            if strcmp(displayName, 'Solution Controller') && isempty(obj.SolutionController)
                obj.SolutionController = module;
            end
            
            if strcmp(displayName, 'Graphing Pre Points') && isempty(obj.GraphingPrePoints)
                obj.GraphingPrePoints = module;
            end
            
            if strcmp(displayName, 'Graphing Amplifier Response') && isempty(obj.GraphingAmplifierResponses)
                obj.GraphingAmplifierResponses = module;
            end
            
            if strcmp(displayName, 'Amplifier Response')
                obj.amplifierResponses = module;
            end
            
            if strcmp(displayName, 'NDFConfiguration')
                obj.ndfConfiguration = module;
            end
        end
        
        function moduleUnRegister(obj, displayName)
            if strcmp(displayName, 'Notepad')
                obj.notepad = [];
            end
            
            if strcmp(displayName, 'Solution Controller')
                obj.SolutionController = [];
            end
            
            if strcmp(displayName, 'Graphing Pre Points')
                obj.GraphingPrePoints = [];
            end
            
            if strcmp(displayName, 'Graphing Amplifier Response')
                obj.GraphingAmplifierResponses = [];
            end
            
            if strcmp(displayName, 'Amplifier Response')
                obj.amplifierResponses = [];
            end
            
            if strcmp(displayName, 'NDFConfiguration')
                obj.ndfConfiguration = [];
            end
        end
        
        %% Multiclamp Functions
        function applyAmpHoldSignal(obj)
            obj.setDeviceBackground(obj.amp, obj.ampHoldSignal, obj.rigConfig.getAmpUnits(obj.amp));
        end
        
        function sendToLog(obj,s)
            if obj.loggingIsValid
                obj.notepad.log(s);
            end
        end
        
        function s = logProperties(obj, propertyString, string)
            if obj.loggingIsValid && isprop(obj, propertyString) && ~isempty(obj.(propertyString))
                property = obj.(propertyString);
                
                if exist('string','var')
                    s = string;
                else
                    s = '';
                end
                
                for f = 1:numel(property)
                    value = obj.( property{f} );
                    
                    if ischar(value)
                        formatSpec = '%s%s: %s%s%s';
                    else
                        formatSpec ='%s%s: %d%s%s';
                    end
                    
                    parameter = obj.parameterProperty(property{f});
                    s = sprintf(formatSpec,s,property{f},value,parameter.units,obj.logTab);
                end
            end
        end
        
        function bool = loggingIsValid(obj)
            bool = false;
            % continueLogging
            if ~isempty(obj.notepad) && obj.notepad.isLogging && obj.allowSavingEpochs
                bool = true;
            end
        end
        
        %% Calibration Functions
        function optometerReading = recordLEDCalibration(~, epoch, lightRange)
            recordedOptometer = epoch.response('Optometer');
            outputRange = 4;
            average = 0;
            
            samples = length(recordedOptometer);
            for i = 1:samples
                average = average + recordedOptometer(i);
            end
            
            if strcmp(lightRange,'pico')
                factor = 4;
            elseif strcmp(lightRange,'micro')
                factor = 2;
            elseif strcmp(lightRange,'nano')
                factor = 3;
            else
                factor = 0;
            end
            
            average = average/samples;
            optometerReading = [num2str((1 - (outputRange - average)) * 10^factor) ' ' lightRange];
        end
        
        %% Heat Controller Functions
        function average = recordSolutionTemp(~, epoch)
            recordedTemp = epoch.response('HeatController');
            samples = length(recordedTemp);
            total = 0;
            
            for i = 1:samples
                total = total + recordedTemp(i);
            end
            
            average = 10 * (total/samples);
            m = 3; % Number of significant decimals, default to 3
            
            if average < 1
                m = 1;
            elseif average < 10
                m = 2;
            elseif average < 100
                m = 3;
            elseif average < 1000
                m = 4;
            end
            
            k = floor(log10(abs(average)))-m+1;
            average = round(average/10^k)*10^k;
        end
        
        %% Background Functions
        function background = getDeviceBackground(obj, name)
            device = obj.rigConfig.deviceWithName(name);
            units = char(device.Background.DisplayUnit);
            baseUnitBackground =  double(System.Convert.ToDouble(device.Background.Quantity));
            
            if strcmp(units, 'V')
                background = baseUnitBackground * 10^3;
            elseif strcmp(units, 'mV')
                background = baseUnitBackground;
            end
        end
    end
    
end

