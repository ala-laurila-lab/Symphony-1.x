classdef LabRigConfiguration < RigConfiguration
    %LABCONFIGURATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axopatchModes
    end
    
    properties (Constant, Hidden)
        timeString = 'HH:MM:SS-dd/mm/yy';
        logTab = '      ';
    end
    
    methods
        %% Overridden functions
        function obj = init(obj, daqControllerFactory)
            obj.axopatchModes.('VClamp') =  'mV';
            obj.axopatchModes.('I0') =  'pA';
            obj.axopatchModes.('IClampNormal') =  'pA';
            obj.axopatchModes.('IClampFast') =  'pA';
            obj.axopatchModes.('Track') =  'mV';
            
            init@RigConfiguration(obj, daqControllerFactory);
        end
        
        %% Log Functions
        function setDeviceBackground(obj, devName, value, devUnit)
            setDeviceBackground@RigConfiguration(obj, devName, value, devUnit);
            formatSpec = '%d%s';
            obj.symphonyUI.protocol.deviceBackgrounds.(devName) = sprintf(formatSpec, value, devUnit);
            if(obj.symphonyUI.protocol.loggingIsValid)
                formatSpec = 'Time:%s%sDevice:%s%s%d%s';
                s = sprintf(formatSpec, datestr(now, obj.timeString), obj.logTab, devName, obj.logTab, value, devUnit);
                obj.symphonyUI.protocol.sendToLog(s);
            end
        end
        
        %% New methods for extra functionality
        function isDevice = isDevice(obj, deviceName)
            isDevice = false;
            
            if ~isempty(obj.deviceWithName(deviceName))
                isDevice = true;
            end
        end
        
        function data = getSingleReadingFromDevice(obj, deviceName)
            import Symphony.Core.*;
            
            %Checking to see if the device exists
            if ischar(deviceName)
                device = obj.deviceWithName(deviceName);
                
                if isempty(device)
                    error('There is no device named ''%s''.', deviceName);
                end
            else
                error('The required input is a string of the device name');
            end
            
            data = {};
            
            [~, streams] = dictionaryKeysAndValues(device.Streams);
            
            %iterate through each stream associated with the device
            for s = 1:length(streams)
                stream = streams{s};
                
                %We only want to retrieve input streams. In addition, we
                %want to make sure that the controller and DAQ are not
                %running
                if isa(stream, 'Symphony.Core.IDAQInputStream') && ...
                        obj.controller.IsRunning == 0 && obj.controller.DAQController.HardwareRunning == 0
                    
                    response = obj.controller.DAQController.ReadStreamAsync(stream);
                    
                    %Add the resulting data to the output variable
                    data{end + 1} = double(Measurement.ToQuantityArray(response.Data)); %#ok<AGROW>
                end
            end
        end
        
        function addStream(obj, device, streamName, isOutStream, name)
            import Symphony.Core.*;
            stream = obj.streamWithName(streamName, isOutStream);
            
            if nargin==5 && ~isempty(name)
                device.BindStream(name,stream);
            else
                device.BindStream(stream);
            end
            
            if isOutStream
                device.OutputSampleRate = Measurement(obj.sampleRate, 'Hz');
            else
                device.InputSampleRate = Measurement(obj.sampleRate, 'Hz');
            end
        end
        
        %% Axopatch Code
        function addAxopatchDevice(obj, deviceName, outStream, inStreamNames)
            import Symphony.Core.*;
            import Symphony.ExternalDevices.*;
            import Symphony.ExternalDevices.*;
            
            modeNames = fieldnames(obj.axopatchModes);
            modeCount = numel(modeNames);
            
            modes = NET.createArray('System.String', modeCount);
            backgroundMeasurements = NET.createArray('Symphony.Core.IMeasurement', modeCount);
            
            for m = 1:modeCount
                currentMode = char(modeNames(m));
                modes(m) = currentMode;
                backgroundMeasurements(m) = Measurement(0, obj.axopatchModes.(currentMode));
            end
            
            dev = AxopatchDevice(Axopatch200B, obj.controller, modes, backgroundMeasurements);
            dev.Name = deviceName;
            dev.Clock = obj.controller.DAQController.Clock;
            
            inputs = {dev.GAIN_TELEGRAPH_STREAM_NAME, 'FREQUENCY_TELEGRAPH', dev.MODE_TELEGRAPH_STREAM_NAME, 'CELL_CAPACITANCE_TELEGRAPH', dev.SCALED_OUTPUT_STREAM_NAME};
            
            for s = 1:numel(inStreamNames)
                if ~isempty(inStreamNames{s})
                    obj.addStream(dev, inStreamNames{s}, false, inputs{s});
                end
            end
            
            obj.addStream(dev,outStream,true);
        end
        
        function mode = axopatchMode(obj, deviceName)
            import Symphony.ExternalDevices.*;
            
            if nargin == 2 && ~isempty(deviceName)
                device = obj.deviceWithName(deviceName);
            else
                devices = obj.axopatchDevices();
                if ~isempty(devices)
                    device = devices{1};
                end
            end
            
            if isempty(device)
                error('Symphony:Axopatch:NoDevice', 'Cannot determine the Axopatch mode because no Axopatch device has been created.');
            end
            
            
            mode = CurrentDeviceParameters.OperatingMode;
        end
        
        function d = axopatchDevices(obj)
            d = {};
            devices = obj.devices();
            for i = 1:length(devices)
                if isa(devices{i}, 'Symphony.ExternalDevices.AxopatchDevice')
                    d{end + 1} = devices{i};
                end
            end
        end
        
        function n = numAxopatchDevices(obj)
            n = length(obj.axopatchDevices());
        end
        
        function names = axopatchDeviceNames(obj)
            names = {};
            devices = obj.axopatchDevices();
            for i = 1:length(devices)
                names{end + 1} = char(devices{i}.Name);
            end
        end
        
        function bool = isAxopatchDevice(obj, amp)
            device = obj.deviceWithName(amp);
            if isa(device, 'Symphony.ExternalDevices.AxopatchDevice')
                bool = true;
            else
                bool = false;
            end
        end
        
        function units = axoPatchUnits(obj, amp)
            device = obj.deviceWithName(amp);
            mode = device.CurrentDeviceParameters.OperatingMode;
            units = obj.axopatchModes.(char(mode));
        end
        
        function mode = axoPatchMode(obj, amp)
            device = obj.deviceWithName(amp);
            mode = device.CurrentDeviceParameters.OperatingMode;
        end
        
        %% Multiclamp Functions
        function bool = isMultiClampDevice(obj, amp)
            device = obj.deviceWithName(amp);
            if isa(device, 'Symphony.ExternalDevices.MultiClampDevice')
                bool = true;
            else
                bool = false;
            end
        end
        
        %% Amplifier Functions
        function units = getAmpUnits(obj, amp)
            if(obj.isMultiClampDevice(amp))
                if strcmp(obj.multiClampMode(amp), 'VClamp')
                    units = 'mV';
                else
                    units = 'pA';
                end
            elseif(obj.isAxopatchDevice(amp))
                units = obj.axoPatchUnits(amp);
            end
        end
        
        function mode = getAmpMode(obj, amp)
            if(obj.isMultiClampDevice(amp))
                mode = obj.multiClampMode(amp);
            elseif(obj.isAxopatchDevice(amp))
                mode = obj.axoPatchMode(amp);
            end
        end
        
        
        function names = ampDeviceNames(obj)
            axopatchNames = obj.axopatchDeviceNames();
            multiclampNames = obj.multiClampDeviceNames();
            
            names = [axopatchNames; multiclampNames];
        end
        
        %% Rig Switches
        function names = getRigSwitcheNames(obj)
            rigSwitches = cell(obj.numberOfRigSwitches,1);
            for s = 0:obj.numberOfRigSwitches-1
                rigSwitches{s+1} = ['Rig_Switches_' int2str(s)];
            end
            
            names = rigSwitches;
        end
        
        function bool = isRigSwitch(obj)
            returnValue = false;
            
            for s = 0:obj.numberOfRigSwitches
                if obj.isDevice(['Rig_Switches_' int2str(s)])
                    returnValue = true;
                    break;
                end
            end
            
            bool = returnValue;
        end
        
    end
end

