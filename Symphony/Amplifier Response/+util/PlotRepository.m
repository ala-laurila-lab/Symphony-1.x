classdef PlotRepository < handle
    %PLOTREPOSITORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = 'private')
        listeners = {};
        folder
    end
    
    properties(Constant)
        
        EXTENSION = '.m'
        START_IDX = 3;
    end
    
    
    methods
        
        function obj = PlotRepository(folder)
            obj.folder = folder;
        end
        
        function  addlistener(obj, source, eventName, transferObject)
            plotDir = dir(fullfile(regexprep(userpath, ';', ''), obj.folder));
            noOfPlots = length(plotDir);
            
            for i = obj.START_IDX:noOfPlots
                name = strrep(plotDir(i).name, obj.EXTENSION, '');
                fig = figure( ...
                    'Name', name, ...
                    'MenuBar', 'none', ...
                    'Toolbar', 'none', ...
                    'NumberTitle', 'off',...
                    'Visible', 'off');
                fun = str2func( ['@(src, data)' name '(src, data,' num2str(fig), transferObject ')']);
                obj.listeners{i - obj.START_IDX + 1} = addlistener(source, eventName, fun);
            end
        end
        
        function clear(obj)
            for i = 1:length(obj.listeners)
                delete(obj.listeners(i))
            end
        end
    end
    
end

