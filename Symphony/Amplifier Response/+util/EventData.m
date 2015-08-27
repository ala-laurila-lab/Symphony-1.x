classdef (ConstructOnLoad) EventData < event.EventData
    
    properties
        key
        value
    end
    methods
        
        function eventData = EventData(key, value)
            eventData.key = key;
            eventData.value = value;
        end
    end
end