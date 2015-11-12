classdef MockEpoch < handle
    %EPOCHTEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        index = 1
        parameters
    end
    
    properties
        REMOTE_PATH = '/archive/ala-laurila_lab/data/takeshd1'
        LOCAL_PATH = './Test/data/'
        FILE = '061915Ac4.h5'
        HOSTNAME = 'amor.becs.hut.fi'
        USERNAME = 'narayas2'
        PASSWORD = 'sowmya@1989'
    end
    
    methods
        function obj = MockEpoch
           if ~exist(fullfile(obj.LOCAL_PATH, obj.FILE) , 'file')
               obj.download; 
               data = CellData('./Test/data/061915Ac4.h5');
               save('cellData.mat', 'data')
           end
            temp = load('cellData.mat');
            obj.data = temp.data;
        end
        
        function [r, s, t] = response(obj, ch)
            [r, s, t] = obj.data.epochs(obj.index).getData;
        end
        
        function nextIndex(obj)
            obj.index = obj.index + 1;        
        end
        
        function p = get.parameters(obj)
            map = obj.data.epochs(obj.index).attributes;
            k = map.keys;
            p = struct();
            for i = 1:length(k)
                p.(k{i}) = map(k{i});
            end
        end
        
        function tf = containsParameter(obj, name)
            tf = false;
        end
        
        function s = toStruct(obj, i)
            s = obj.parameters;
            [r, ~, ~] = obj.data.epochs(i).getData;
            s.response = r';
        end
        
        %save('data.json', e.hdf5toJson(1,10), '-ascii');
        function data = hdf5toJson(obj, start, n)
            responses = [];
            for i = start:n
                responses = [obj.toStruct(i), responses];
            end
            data = savejson('data',responses);
        end
        
        function download(obj)
            con = ssh2_config(obj.HOSTNAME, obj.USERNAME, obj.PASSWORD);
            disp('connected to amor .. Downloading file..');
            con = scp_get(con, {obj.FILE}, obj.LOCAL_PATH , obj.REMOTE_PATH);
            disp('Download complete !');
            ssh2_close(con);
        end
    end
end

