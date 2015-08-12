classdef Model < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        foo
    end
    
    events
        bar
    end
    
    methods
        
        function obj = Model()
        end
        
        function setFoo(obj, val)
            obj.foo = val;
            if val == 1
                notify(obj, 'bar', TestEvenData(obj.foo));
            end
        end
    end
    
end

