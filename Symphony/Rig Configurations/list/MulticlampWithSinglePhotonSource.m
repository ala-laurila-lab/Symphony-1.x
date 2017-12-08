classdef MulticlampWithSinglePhotonSource < LabRigConfiguration
    
    properties (Constant)
        displayName = 'MulticlampWithSinglePhotonSource'
        numberOfRigSwitches = 4;
        RIG_DESC = 'Viiki Patch Rig'
        RIG_NAME = 'A'
    end
    
    properties(SetAccess = private)
        filterWheels = containers.Map();
        singlePhotonSourceClient
    end

    methods   
        %% Note: The names of the devices are important, the can not be changed!
        function createDevices(obj)
             obj.addMultiClampDevice('Amplifier_Ch1', 1, 'ANALOG_OUT.0', 'ANALOG_IN.0');
             obj.addMultiClampDevice('Amplifier_Ch2', 2, 'ANALOG_OUT.1', 'ANALOG_IN.1'); % If adding a 3rd LED Channel, this line needs to be commented out 

            %% LED Devices
            obj.addDevice('Ch1', 'ANALOG_OUT.2', '');
            obj.addDevice('Ch2', 'ANALOG_OUT.3', '');

            %% Adding the heat controller
            obj.addDevice('HeatController', '', 'ANALOG_IN.2');

            %% Adding the Optometer
            % obj.addDevice('Optometer', '', 'ANALOG_IN.3'); %Uncomment if you are using the optometer, make sure the correcct channel is being used
            
            %% Adding the Rig Switches
            obj.addDevice('Rig_Switches_0','', 'DIGITAL_IN.0');  % input only
            obj.addDevice('Rig_Switches_1','', 'DIGITAL_IN.1');  % input only
            obj.addDevice('Rig_Switches_2','', 'DIGITAL_IN.2');  % input only
            obj.addDevice('Rig_Switches_3','', 'DIGITAL_IN.3');  % input only
%             obj.addDevice('Rig_Switches_4','', 'DIGITAL_IN.4');  % input only
%             obj.addDevice('Rig_Switches_5','', 'DIGITAL_IN.5');  % input only
%             obj.addDevice('Rig_Switches_6','', 'DIGITAL_IN.6');  % input only
%             obj.addDevice('Rig_Switches_7','', 'DIGITAL_IN.7');  % input only
%             obj.addDevice('Rig_Switches_8','', 'DIGITAL_IN.8');  % input only
%             obj.addDevice('Rig_Switches_9','', 'DIGITAL_IN.9');  % input only
%             obj.addDevice('Rig_Switches_10','', 'DIGITAL_IN.10');  % input only
%             obj.addDevice('Rig_Switches_11','', 'DIGITAL_IN.11');  % input only
%             obj.addDevice('Rig_Switches_12','', 'DIGITAL_IN.12');  % input only
%             obj.addDevice('Rig_Switches_13','', 'DIGITAL_IN.13');  % input only
            
            %% Adding the TTL Trigger
            obj.addDevice('Oscilloscope_Trigger', 'DIGITAL_OUT.0', '');
            % Adding the Shutter Trigger - This channel is for driving a shutter from thorlabs setup
            obj.addDevice('Shutter_Trigger', 'DIGITAL_OUT.1', '');
            % Adding another Shutter Trigger as per Daisuke and Krishna suggestion.
            % Reason : This channel is for driving a shutter from Uniblit
            % If you happend to comment below line of code please change the method SinglePhoton@hasValidShutter accordingly
            obj.addDevice('Shutter_Trigger_Secondary', 'DIGITAL_OUT.2', '');
                        
            % Adding filter wheel configuration
            wheelconfigs = FilterWheelConfig.listByRigName(obj.RIG_NAME);
            for i = 1:numel(wheelconfigs)
                config = wheelconfigs(i);
                obj.filterWheels(char(config)) = FilterWheel(config);
            end
            
            % create TCP client object for singlePhoton source
            obj.singlePhotonSourceClient = SinglePhotonSourceClient('128.214.235.108', 5020);
        end 
    end
end