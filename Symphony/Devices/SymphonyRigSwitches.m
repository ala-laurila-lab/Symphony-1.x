classdef SymphonyRigSwitches < handle
    properties
        % These are the functions tied to every switch
        
        % Examples
        %         switchOne = {'pauseProtocol'};
        %         switchTwo = {'stopProtocol'};
        %         switchThree = {'startProtocol'};
        
        % These are the available switches. The value in the cell eg,
        % 'runProtocol' is a function that you have to create and place in
        % this file (switch control functions start at line 156).
        switchOne = {'runProtocol'};
        switchTwo = {'dontSave'};
        switchThree = {'updateFigures'};
        switchFour = {'stopProtocol'};
        switchFive = {''};
        switchSix = {''};
        switchSeven = {''};
        switchEight = {''};
    end
    
    properties (Hidden)
        switches
        totalSwitchValue
        switchListNo
        protocol
        rigConfig
        numberOfRepeats = []
        symphonyUI
    end
    
    methods
        function obj = SymphonyRigSwitches(protocol, rigConfig, symphonyUI)
            obj.protocol = protocol;
            obj.rigConfig = rigConfig;
            obj.symphonyUI = symphonyUI;
            obj.switches = {};
            
            switchList = properties(obj);
            obj.switchListNo = numel(switchList);
            
            % Creating the struct that contains all the switches
            % information
            for switchIndex = 1:obj.switchListNo
                name = switchList{switchIndex};
                
                obj.switches{switchIndex} = struct();
                obj.switches{switchIndex}.( 'switchFunction' ) = obj.( name ){1};
                obj.switches{switchIndex}.( 'state' ) = 0;
                obj.switches{switchIndex}.( 'switchPostion' ) = 2^(switchIndex - 1);
            end
            
            obj.totalSwitchValue = 0;
        end
        
        %% Get Reading
        function checkStatus(obj)
            response = obj.rigConfig.getSingleReadingFromDevice('Rig_Switches_0');
            samples = length(response{1});
            
            if samples > 0
                bitMaskTotal = response(samples);
                obj.changeState(bitMaskTotal{1});
            end
        end
        
        function changeState(obj, bitMaskTotal)
            %converting the number recieved to its binary form
            binary = dec2bin(bitMaskTotal,8);
            binaryString = num2str(binary);
            
            % Find the location of any on switches and off switches
            onSwitches = strfind(binaryString, '1');
            offSwitches = strfind(binaryString, '0');
            for os = 1:length(onSwitches)
                % Binary numbers read from right to left so we have to change the direction
                switchIndex = (8 - onSwitches(os)) + 1;
                obj.setState(switchIndex,1);            
            end
            for os = 1:length(offSwitches)                % Binary numbers read from right to left so we have to change the direction
                switchIndex = (8 - offSwitches(os)) + 1;
                obj.setState(switchIndex,0);
            end
        end
        
        %% Switch Change Functions
        
        % reading in the digital input to determine which switches were
        % changed
        function switchesChanged(obj, response, index)
            samples = length(response);
            
            if samples > 0
                state = response(samples);
                obj.setState(index, state);
            end
        end
        
        % Setting the state of the switch that has been changed
        function setState(obj, switchIndex, value)
            obj.switches{switchIndex}.( 'state' ) = value;
            functionName = obj.switches{switchIndex}.( 'switchFunction' );
            
            %if value == 1
            try
                obj.( functionName )(value);
            catch
                %Not a function, who cares lets not run it
            end
            %end
        end
        
        %% Switch control functions
        % The value is that state of the switch.
        %   - value = 0 when the switch is down
        %   - value = 1 when the switch is up
        function dontSave(obj , value )
            if value == 0
                obj.protocol.allowSavingEpochs = false;
                obj.protocol.persistor = [];
                set(obj.symphonyUI.controls.saveEpochsCheckbox, 'Value', 0)
            else
                obj.protocol.allowSavingEpochs = true;
                obj.protocol.persistor = obj.symphonyUI.persistor;
                set(obj.symphonyUI.controls.saveEpochsCheckbox, 'Value', 1)
            end
        end
        
        function runProtocol(obj , value )
            if value == 1
                obj.protocol.finishAfterRepeat = false;
            else
                obj.protocol.finishAfterRepeat = true;
            end
        end
        
        function updateFigures(obj , value )
            if value == 1
                obj.protocol.graphing = true;
            else
                obj.protocol.graphing = false;
            end
        end
        
        function stopProtocol(obj , value)
            if value == 0 && strcmp(obj.protocol.state, 'running');
                obj.protocol.stop();
            end
        end
    end
end