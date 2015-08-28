classdef GenericTO < handle
    %GENERICTO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        transient;
        persistant;
    end
    
    methods
        
        function obj = GenericTO()
            obj.transient = struct();
            obj.persistant = struct();
        end
    end
    
end