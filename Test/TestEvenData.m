classdef (ConstructOnLoad) TestEvenData < event.EventData
   properties
      value;
   end
   methods
      function eventData = TestEvenData(value)
         eventData.value = value;
      end
   end
end