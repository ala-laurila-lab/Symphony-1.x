classdef GraphingConstants
    
    enumeration
        COLOR_SET(constants.Colors.getColorEnums());
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
             v = {false, c.getValue(), 0, 1, 'r*'};
             p = containers.Map(GraphingConstants.MAIN_GRAPH_PROPERTIES_KEY.cell, v);
        end
    end
end

