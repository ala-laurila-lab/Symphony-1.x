classdef FilterWheelConfig
    
    properties
        rigName
        wheelName
        ndfContainer
        posContainer
        port
        motorized
        active
    end
    
    methods
        
        function obj = FilterWheelConfig(rigName, wheelName, ndfNames, ndfPositions, port, motorized, active)
            obj.rigName = rigName;
            obj.wheelName = wheelName;
            obj.ndfContainer = containers.Map(ndfNames, ndfPositions);
            obj.posContainer = containers.Map(ndfPositions, ndfNames);
            obj.port = port;
            obj.motorized = motorized;
            obj.active = active;
        end
    end
    
    methods(Static)
        
        function configByName = listByRigName(name, filter)
            if nargin < 2
                filter = @(config) config.active == true;
            end
            
            configs = enumeration('FilterWheelConfig');
            configByName = [];
            for i = 1:numel(configs)
                if strcmpi(configs(i).rigName, name) && filter(configs(i))
                    configByName = [configByName; configs(i)]; %#ok
                end
            end
        end
    end
    
    enumeration
        VIIKKI_PATCH_RIG_WHEEL_1('A', 'Ch1 Motorized', {'0.3A', '1A', '2A', '3A', '4B', 'Empty'}, [1, 2, 3, 4, 5, 6],  'COM12', true, true);
        VIIKKI_PATCH_RIG_WHEEL_2('A', 'Ch2 Motorized', {'0.3B', '1B', '2B', '3B', '4D', 'Empty'}, [1, 2, 3, 4, 5, 6],  'COM15', true, true);
        VIIKKI_PATCH_RIG_WHEEL_3('A', 'Ch1 Manual', {'4A', 'None'}, [1, 2], 'Manual', false, true);
        VIIKKI_PATCH_RIG_WHEEL_4('A', 'Ch2 Manual', {'4C', 'None'}, [1, 2], 'Manual', false, true);
    end
end

