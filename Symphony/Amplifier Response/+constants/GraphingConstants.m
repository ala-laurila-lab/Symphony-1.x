classdef GraphingConstants
    
    enumeration
        COLOR_SET({'red', 'blue', 'green', 'yellow', 'magenta', 'cyan', 'white'});
        MAIN_GRAPH_PROPERTIES_KEY({'active', 'color', 'shift', 'scale', 'marker'})
        LED_PROTOCOL_PARAMETERS({
            'initialPulseAmplitude',...
            'scalingFactor',...
            'preTime',...
            'stimTime',...
            'tailTime',...
            'numberOfIntensities',...
            'numberOfRepeats',...
            'interpulseInterval',...
            'ampHoldSignal',...
            'backgroundAmplitude'})
    end
    
    properties
        cell
    end
    
    methods
        function obj = GraphingConstants(cell)
            obj.cell = cell;
        end
    end
    
    methods(Static)
        function p = getMainGraphProperties(idx)
            import constants.*;
             c = GraphingConstants.COLOR_SET.cell{idx};
             v = {false, c, 0, 1, 'b*'};
             p = containers.Map(GraphingConstants.MAIN_GRAPH_PROPERTIES_KEY.cell, v);
        end
    end
end

