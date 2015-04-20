classdef Axopatch < LabRigConfiguration
    
    properties (Constant)
        displayName = 'Axopatch'
        numberOfRigSwitches = 8
    end  
    
    methods
        function obj = init(obj, daqControllerFactory)
            init@LabRigConfiguration(obj, daqControllerFactory);
        end
        
        %% Note: The names of the devices are important, the can not be changed!
        function createDevices(obj)
            % The axopatch streams have to be entered in the folling order:
            % GAIN, FREQUENCY, MODE, CELLCAPACITANCE, SCALED OUTPUT
            % Leave a blank string if it is not connected
            obj.addAxopatchDevice('Axopatch', 'ANALOG_OUT.0', {'ANALOG_IN.0', 'ANALOG_IN.1', 'ANALOG_IN.2', 'ANALOG_IN.3', 'ANALOG_IN.4'});
            
            %% LED Devices
            obj.addDevice('Ch1', 'ANALOG_OUT.1', '');
            obj.addDevice('Ch2', 'ANALOG_OUT.2', '');
            obj.addDevice('Ch3', 'ANALOG_OUT.3', '');
            
            %% Adding the heat controller
            obj.addDevice('HeatController', '', 'ANALOG_IN.5');
            
            %% Adding the Optometer
            % obj.addDevice('Optometer', '', 'ANALOG_IN.5'); %Uncomment if you are using the optometer, make sure the correcct channel is being used
            
            %% Adding the Rig Switches
            obj.addDevice('Rig_Switches_0','', 'DIGITAL_IN.0');  % input only
            obj.addDevice('Rig_Switches_1','', 'DIGITAL_IN.1');  % input only
            obj.addDevice('Rig_Switches_2','', 'DIGITAL_IN.2');  % input only
            obj.addDevice('Rig_Switches_3','', 'DIGITAL_IN.3');  % input only
            obj.addDevice('Rig_Switches_4','', 'DIGITAL_IN.4');  % input only
            obj.addDevice('Rig_Switches_5','', 'DIGITAL_IN.5');  % input only
            obj.addDevice('Rig_Switches_6','', 'DIGITAL_IN.6');  % input only
            obj.addDevice('Rig_Switches_7','', 'DIGITAL_IN.7');  % input only
            
            %% Adding the TTL Trigger
            obj.addDevice('Oscilloscope_Trigger', 'DIGITAL_OUT.1', '');
        end
    end
end