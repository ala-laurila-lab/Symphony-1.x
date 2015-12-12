classdef FilterWheel < handle
    
    properties (Access = private)
        com
        wheelConfig
        currentndf
    end
    
    methods
        
        function obj = FilterWheel(wheelConfig)
            if wheelConfig.motorized
                obj.com = serial(wheelConfig.port, 'BaudRate', 115200, 'DataBits', 8, 'StopBits', 1, 'Terminator', 'CR');
            end
            obj.wheelConfig = wheelConfig;
        end
        
        function setNDF(obj, ndf)
            
            if ~isKey(obj.wheelConfig.ndfContainer, ndf)
                disp(['Error: filter value ' ndf ' not found']);
                return;
            end
            
            if ~ obj.wheelConfig.motorized
                obj.currentndf = ndf;
                return
            end
            
            pos = obj.wheelConfig.ndfContainer(ndf);
            if pos ~= obj.getPosition()
                fopen(obj.com);
                fprintf(obj.com, ['pos=' num2str(pos) '\n']);
                pause(4);
                fclose(obj.com);
            end
            obj.currentndf = ndf;
        end
        
        function pos = getPosition(obj)
            fopen(obj.com);
            try
                fprintf(obj.com, 'pos?\n');
                pause(0.2);
                while (get(obj.com, 'BytesAvailable')~=0)
                    txt = fscanf(obj.com, '%s');
                    if txt == '>'
                        break;
                    end
                    pos= txt;
                end
                pos = str2num(pos);
            catch
                disp('Read error from NDF');
            end
            fclose(obj.com);
        end
        
        function str = getNDFIdentifier(obj)
            if isempty(obj.getNDF())
               str = 'NA'; 
               return;
            end
            str = strcat(obj.wheelConfig.rigName, obj.getNDF());
        end
        
        function ndf = getNDF(obj)
            ndf = [];
            wc = obj.wheelConfig;
            
            if  obj.wheelConfig.motorized
                ndf = wc.posContainer(obj.getPosition());
            elseif ~isempty(obj.currentndf)
                ndf = obj.currentndf;
            end
        end
        
        function delete(obj)
            delete(obj.com);
        end
    end
end