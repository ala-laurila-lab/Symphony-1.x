classdef Multiclamp < LabRigConfiguration
    
    properties (Constant)
        displayName = 'Multiclamp'
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
%             obj.addDevice('HeatController', '', 'ANALOG_IN.2');

            %% Adding the Optometer
%             obj.addDevice('Optometer', '', 'ANALOG_IN.3'); %Uncomment if you are using the optometer, make sure the correcct channel is being used
            
            %% Adding the Rig Switches
 			obj.addDevice('RigSwitches','', 'DIGITAL_IN.0');  % input only
            
            %% Adding the TTL Trigger
            obj.addDevice('Oscilloscope_Trigger', 'DIGITAL_OUT.1', '');
        end 
    end
end