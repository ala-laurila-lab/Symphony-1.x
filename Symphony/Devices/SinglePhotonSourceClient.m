classdef SinglePhotonSourceClient < handle
    
    properties (Access = private)
        clientSocket
        ip
        port
    end
    
    methods
        
        function obj = SinglePhotonSourceClient(ip, port)
            obj.ip = ip;
            obj.port = port;
        end
        
        function response = sendReceive(obj, protocol)
            tic;
            obj.createSocket();
            obj.send(savejson('', protocol, ''));
            response = obj.recieve();
            obj.close();
            elapsedTime = toc;
            disp(['elapsed time - ' num2str(elapsedTime)]);
        end
        
        function close(obj)
            if ~ isempty(obj.clientSocket)
                obj.clientSocket.close();
                obj.clientSocket = [];
            end
        end
    end
    
    methods (Access = private)
        
        function send(obj, request)
            requestJson = java.lang.String(request);
            dataOutPutStream = java.io.DataOutputStream(obj.clientSocket.getOutputStream());
            dataOutPutStream.writeBytes(requestJson); % UTF String json
        end
        
        function response = recieve(obj)
            bufferedReader = java.io.BufferedReader(java.io.InputStreamReader(obj.clientSocket.getInputStream()));
            line = bufferedReader.readLine();
            response = char(line);
        end
        
        function createSocket(obj)
            try
                obj.close();
                obj.clientSocket = java.net.Socket(obj.ip, obj.port);
            catch exception
                obj.clientSocket = [];
                throw(exception)
            end
        end
    end
end

