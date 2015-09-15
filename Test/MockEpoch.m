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
        
        function download(obj)
            con = ssh2_config(obj.HOSTNAME, obj.USERNAME, obj.PASSWORD);
            disp('connected to amor .. Downloading file..');
            con = scp_get(con, {obj.FILE}, obj.LOCAL_PATH , obj.REMOTE_PATH);
            disp('Download complete !');
            ssh2_close(con);
        end
    end
end

