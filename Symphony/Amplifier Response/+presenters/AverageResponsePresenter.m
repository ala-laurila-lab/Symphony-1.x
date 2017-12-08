classdef AverageResponsePresenter < Presenter
    
    properties
        averageService
        channels
    end
    
    methods(Access = protected)
        
        function onGoing(obj)
            v = obj.view;
            chs = obj.averageService.keys;
            s = obj.averageService(chs{1});
            groupBy = s.getGroupByLabel();
            v.setControlsLayout(groupBy, chs);
            obj.channels = chs;
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'ShowAverageResponse', @obj.viewAverageResponse);
            obj.addListener(v, 'HoldAverageResponse', @obj.holdResponse);
            obj.addListener(v, 'EraseHoldingResponse', @obj.clearHoldResponse);
            obj.addListener(v, 'ShowAllAverageResponse', @obj.viewAllAverageResponse);
        end
        
        function onStopping(obj)
            v = obj.view;
            obj.clearHoldResponse();
            v.saveFigureHandlePosition();
        end
    end
    
    methods
        
        function obj = AverageResponsePresenter(service, view)
            if nargin < 2
                view = views.AverageResponseView();
            end
            obj@Presenter(view);
            obj.averageService = service;
        end
        
        % Desc - check for the selected channel & stimuls index
        % collect all plot handles for average response and return the same
        %
        % Reason - On activate of hold grap button, the current state of
        % active graph should be persisted and should be displayed on
        % concurrent epochs, see @holdResponse @viewAverageResponseForChannels
        
        function [handles, channel, idx] = getGraphHandles(obj)
            import constants.*;
            legends = GraphingConstants.COLOR_SET.cell;
            
            v = obj.view;
            idx = v.getSelectedVoltageIndex();
            handles = cell(1, length(idx));
            channel = v.getSelectedChannel();
            
            for i = 1:length(idx)
                s = obj.averageService(channel);
                [x, y] = s.getAvgResponse(idx(i));
                handles{i} = @()v.plot(x, y, 'color', legends{idx(i)}.getValue());
            end
        end
        
        % Display average response of active stimuls index
        % Dispay the holding graph if any
        
        function viewAverageResponse(obj, ~, ~)
            v = obj.view;
            cellfun(@(graph) graph() ,obj.getGraphHandles());
            
            holdingGraphs = setdiff(obj.averageService.keys, obj.channels);
            for i = 1 : length(holdingGraphs)
                graph = obj.averageService(holdingGraphs{i});
                graph();
            end
            v.resetGraph();
            v.renderGraph();
        end
        
        function viewAllAverageResponse(obj, ~, ~)
            v = obj.view;
            tf = v.hasAllVoltagesChecked();
            if ~tf
                obj.view.clearGraph();
                obj.view.resetGraph();
            end
            v.setAllVoltages(tf);
            obj.viewAverageResponse();
        end
        
        % Get the current state of graph handles and store in
        % averageService cache with key as 'amp1-10-hold'
        % Key description - channel with stimuls is on hold for graphical
        % display
        
        function holdResponse(obj, ~, ~)
            
            [handles, channel, idx] = obj.getGraphHandles();
            for i = 1:length(handles)
                obj.averageService([channel '-' int2str(idx(i)) '-hold']) =  handles{i};
            end
        end
        
        function clearHoldResponse(obj, ~, ~)
            holdingGraphs = setdiff(obj.averageService.keys, obj.channels);
            remove(obj.averageService, holdingGraphs);
            obj.view.clearGraph();
            obj.view.resetGraph();
        end
    end
end

