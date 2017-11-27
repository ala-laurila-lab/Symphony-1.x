classdef SinglePhotonSourceClient < handle
    
    properties (Access = private)
        clientSocket
        ip
        port
    end
    
    properties (Constant)
        REQUEST_PHOTON_RATE_ACTION = 0
        REQUEST_STIMULATION_ACTION = 1
        MAX_SIZE_IN_BYTES = 500;
        DEBUG = true;
    end

    methods
        
        function obj = SinglePhotonSourceClient(ip, port)
            obj.ip = ip;
            obj.port = port;
        end
        
        function [response, responseJson] = sendReceive(obj, protocol, action)
            tic;
            obj.createSocket();
            requestJson = obj.createRequest(protocol, action);
            obj.send(requestJson);
            
            pause(0.5); 
            [response, responseJson] = obj.recieve();

            obj.close();
            elapsedTime = toc;
            if obj.DEBUG disp(['elapsed time for request and response - ' num2str(elapsedTime)]); end;
        end
        
        function close(obj)
            if ~ isempty(obj.clientSocket)
                obj.clientSocket.close();
                obj.clientSocket = [];
            end
        end
    end
    
    methods (Access = private)
        
        function requestJson = createRequest(obj, protocol, action)
            request = struct();
            
            if action == obj.REQUEST_PHOTON_RATE_ACTION
                request.preTime = protocol.preTime;
                request.stimTime = protocol.stimTime;
                request.tailTime = protocol.tailTime;
                request.sourceType = protocol.sourceType;
                request.photonRate = protocol.photonRate;
            end
            
            if action == obj.REQUEST_STIMULATION_ACTION
                request.action = action;
            end
            
            requestJson = savejson('', request, 'Compact', true);
            metaInfo = whos('requestJson');
            if obj.DEBUG disp(['Request size in bytes = ' num2str(metaInfo.bytes)]); end
            
            elapsedBytes = obj.MAX_SIZE_IN_BYTES - metaInfo.bytes;
            padding = repmat(' ', 1, elapsedBytes / 2);
            requestJson = [requestJson padding];

            metaInfo = whos('requestJson');
            if obj.DEBUG disp([ 'Request size in bytes after padding = '  num2str(metaInfo.bytes) ' bytes; Json : ' requestJson]); end
        end

        function send(obj, request)
            requestJson = java.lang.String(request);
            dataOutPutStream = java.io.DataOutputStream(obj.clientSocket.getOutputStream());
            dataOutPutStream.writeBytes(requestJson); % UTF String json
        end
        
        function [response, responseJson] = recieve(obj)
            bufferedReader = java.io.BufferedReader(java.io.InputStreamReader(obj.clientSocket.getInputStream()));
            line = bufferedReader.readLine();
            responseJson = char(line);
            
            if obj.DEBUG disp(['response json: ' responseJson]); end
            response = loadjson(responseJson);
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

