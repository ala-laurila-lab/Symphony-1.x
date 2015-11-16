classdef Colors
    
    properties
        R = 0;
        G = 0;
        B = 0;
    end
    
    methods
        function c = Colors(r,g,b)
            c.R = r; c.G = g; c.B = b;
        end
        
        function v = getValue(obj)
            v = [obj.R, obj.G, obj.B];
        end
    end
    
    methods(Static)
        
        function colorCell = getColorEnums()
            [enums, ~] = enumeration('constants.Colors');
            n = numel(enums);
            
            colorCell = cell(1, n);
            for i= 1:n
                colorCell{i} = enums(i);
            end
        end
        
        function value = getBackGround()
           value =  [0.2, 0.2 ,0.2];
        end
    end
    
    enumeration
        Green     (0, 1, 0)
        Red       (1, 0, 0)
        Blue      (0, 0, 1)
        Yellow    (1, 1, 0)
        Cyan      (0, 1, 1)
        Magenta   (1, 0, 1)
        White     (1, 1, 1)
        DarkRed   (0.5, 0, 0)
        DarkGreen (0, 0.5, 0)
        DarkBlue  (0, 0, 0.5)
        LightGreen(0.5, 0.5, 0)
        Pink      (0.5, 0, 0.5)
        LightBlue (0, 0.5, 0.5)
        Grey      (0.5, 0.5, 0.5)
    end
end