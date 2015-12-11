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
        
        function obj = FilterWheelConfig(rigName, wheelName, ndfValues, ndfPositions, port, motorized, active)
            obj.rigName = rigName;
            obj.wheelName = wheelName;
            obj.ndfContainer = containers.Map(ndfValues, ndfPositions);
            obj.posContainer = containers.Map(ndfPositions, ndfValues);
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

        function ndfIds = getMotorizedNdfIdsByRigName(name)
            configs = enumeration('FilterWheelConfig');
            ndfIds = [];
            for i = 1:numel(configs)
                if strcmpi(configs(i).rigName, name) && configs(i).active == true && configs(i).motorized == true
                    ndfId = cellfun(@(k) strcat(configs(i).rigName, num2str(k), configs(i).wheelName), configs(i).ndfContainer.keys, 'UniformOutput', false);
                    ndfIds = [ndfIds, ndfId]; %#ok
                end
            end
        end
    end
    
    enumeration
        
        PATCH_RIG_VIIKKI_A('A', 'A', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], [1, 2, 3, 4, 5, 6],  'COM18', false, true);
        PATCH_RIG_VIIKKI_B('A', 'B', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], [1, 2, 3, 4, 5, 6], 'Manual', false, true);
    end
end

