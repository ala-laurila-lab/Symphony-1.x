classdef Multiclamp < LabRigConfiguration
    
    properties (Constant)
        displayName = 'Multiclamp'
        numberOfRigSwitches = 4;
    end
    
    methods   
        %% Note: The names of the devices are important, the can not be changed!
        function createDevices(obj)
             obj.addMultiClampDevice('1_Amplifier_Ch1', 1, 'ANALOG_OUT.0', 'ANALOG_IN.0');
             obj.addMultiClampDevice('1_Amplifier_Ch2', 2, 'ANALOG_OUT.1', 'ANALOG_IN.1'); 
             obj.addMultiClampDevice('2_Amplifier_Ch1', 1, 'ANALOG_OUT.2', 'ANALOG_IN.2');   
             obj.addMultiClampDevice('2_Amplifier_Ch1', 2, 'ANALOG_OUT.3', 'ANALOG_IN.3'); 
            %% LED Devices
            obj.addDevice('Ch1', 'ANALOG_OUT.4', '');
            obj.addDevice('Ch2', 'ANALOG_OUT.5', '');

            %% Adding the heat controller
            obj.addDevice('HeatController', '', 'ANALOG_IN.4');

            %% Adding the Optometer
%             obj.addDevice('Optometer', '', 'ANALOG_IN.3'); %Uncomment if you are using the optometer, make sure the correcct channel is being used
            
            %% Adding the Rig Switches 
            %TODO Fix rig switches due to change in IO BUS for ITC 1600

%            obj.addDevice('Rig_Switches_0','', 'DIGITAL_IN.0');  % input only
%            obj.addDevice('Rig_Switches_1','', 'DIGITAL_IN.1');  % input only
%            obj.addDevice('Rig_Switches_2','', 'DIGITAL_IN.2');  % input only
%            obj.addDevice('Rig_Switches_3','', 'DIGITAL_IN.3');  % input only
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
            obj.addDevice('Oscilloscope_Trigger', 'DIGITAL_OUT.1', '');
        end 
    end
end