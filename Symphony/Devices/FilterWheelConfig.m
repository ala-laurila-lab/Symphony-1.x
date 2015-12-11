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
        VIIKKI_PATCH_RIG_WHEEL_1('A', 'wheel_1', {'0.1A', '0.2A', '0.3A', '0.3B', '0.4A', '0.5A'}, [1, 2, 3, 4, 5, 6],  'COM18', false, true);
        VIIKKI_PATCH_RIG_WHEEL_2('A', 'wheel_2', {'0.1B', '0.2B', '0.3C', '0.4B', '0.5B', '0.6A'}, [1, 2, 3, 4, 5, 6], 'Manual', false, true);
    end
end

