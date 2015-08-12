classdef PlotRepository < handle
    %PLOTREPOSITORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = 'private')
        listeners = {};
    end
    
    properties(Constant)
        DIR =  fullfile(regexprep(userpath, ';', ''), 'Plots')
        EXTENSION = '.m'
        START_IDX = 3;
    end
    
    methods
        
        function obj = PlotRepository(source, eventName)
            plotDir = dir(obj.DIR);
            noOfPlots = length(plotDir);
            for i = obj.START_IDX:noOfPlots
                name = strrep(plotDir(i).name, obj.EXTENSION, '');
                fig = figure( ...
                    'Name', 'Graphical Amplifier Response', ...
                    'MenuBar', 'none', ...
                    'Toolbar', 'none', ...
                    'NumberTitle', 'off',...
                    'Visible', 'off');
                fun = str2func( ['@(src, data)' name '(src, data,' num2str(fig) ')']);
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

