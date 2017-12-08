classdef SinglePhotonSourceClient < handle
    
    properties (Access = private)
        clientSocket
        ip
        port
        retryCount
    end
    
    properties (Constant)
        REQUEST_GET_PHOTON_RATE_ACTION = 0
        REQUEST_SET_PARAMETERS_ACTION = 1
        REQUEST_SET_PARAMETERS_STATUS_ACTION = 2
        MAX_SIZE_IN_BYTES = 125;
        DEBUG = false;
        POLL_INTERVAL_IN_SEC = 1   
        MAX_RETRY_COUNT = 10
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
            [response, responseJson] = obj.recieve();
            obj.close();
            
            elapsedTime = toc;
            if obj.DEBUG, disp(['elapsed time for request and response - ' num2str(elapsedTime)]); end;

            switch lower(response.status)
                case 'accepted'
                    obj.startPolling(protocol, obj.REQUEST_SET_PARAMETERS_STATUS_ACTION);
                case 'notready'
                    obj.continuePolling(protocol, obj.REQUEST_SET_PARAMETERS_STATUS_ACTION);
                case 'success'
                    return   
                otherwise
                    error(response.message);
            end
        end
        
        function close(obj)
            if ~ isempty(obj.clientSocket)
                obj.clientSocket.close();
                obj.clientSocket = [];
            end
        end
    end
    
    methods (Access = private)
        
        function startPolling(obj, protocol, action)
            obj.retryCount = 1;
            pause(obj.POLL_INTERVAL_IN_SEC);
            obj.sendReceive(protocol, action);
            if obj.DEBUG, disp('started polling'); end;
        end

        function continuePolling(obj, protocol, action)
            if obj.retryCount > obj.MAX_RETRY_COUNT
                error('Retry attempt exceded');
            end
            obj.retryCount = obj.retryCount + 1;
            pause(obj.POLL_INTERVAL_IN_SEC);
            obj.sendReceive(protocol, action);
            if obj.DEBUG, disp(['continue polling #' num2str(obj.retryCount)]); end;
        end


        function requestJson = createRequest(obj, protocol, action)
            request = struct();
            
            switch action 
                case obj.REQUEST_SET_PARAMETERS_ACTION
                    request.preTime = protocol.preTime;
                    request.stimTime = protocol.stimTime;
                    request.tailTime = protocol.tailTime;
                    request.sourceType = protocol.sourceType;
                    request.photonRate = protocol.photonRate;
            end

            request.action = action;            
            requestJson = savejson('', request, 'Compact', true);
            metaInfo = whos('requestJson');
            if obj.DEBUG, disp(['Request size in bytes = ' num2str(metaInfo.bytes)]); end
            
            elapsedBytes = 2 * obj.MAX_SIZE_IN_BYTES - metaInfo.bytes;
            padding = repmat(' ', 1, elapsedBytes / 2);
            requestJson = [requestJson padding];

            metaInfo = whos('requestJson');
            if obj.DEBUG, disp([ 'Request size in bytes after padding = '  num2str(metaInfo.bytes) ' bytes; Json : ' requestJson]); end
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
            
            if obj.DEBUG, disp(['response json: ' responseJson]); end
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

