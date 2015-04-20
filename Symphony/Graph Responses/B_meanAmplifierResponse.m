classdef B_meanAmplifierResponse < handle
    %MEANRESPONSE : Amplifier
    %   Plotting the amplifier response(n-1) / (n-1)
    %
    
    %% Specific class properties
    % Properties that are required by this class
    properties (Hidden)
        meanPlots
        meanParamNames             
    end
    
    %% Required Properties
    % properties that are required by all responses. It will throw an error without these.
    % These are properties that you can modify.    
    properties
        lineColor = 'white' % you can use [0 0 0] notation as well
        showResponse = true % True the response will graph automatically
        caption = 'Mean Amplifier Response' % The name listed on the plot GUI
        canSave = true %When Hold graph is pressed in the GUI, do you want this plot to remain?
        multipleGraphsCanHold = false % do you want this graph to be held through iterations?
        lastPlot %if can save is true, this is the variable where you have to store the graph you want saved 
    end
    
    %% Required Methods
    methods
        function obj = B_meanAmplifierResponse
            obj.clearFigure();
            obj.lastPlot = struct();
        end
        
        % This is a required function, without it Matlab will through an
        % error. This is where you clean up any properties etc... before a
        % new run        
        function clearFigure(obj)
            obj.meanPlots = struct('params', {}, ...        % The params that define this class of epochs.
                'data', {}, ...          % The mean of all responses of this class.
                'sampleRate', {}, ...    % The sampling rate of the mean response.
                'units', {}, ...         % The units of the mean response.
                'count', {});       % The handle of the plot for the mean response of this class.
            obj.lastPlot = struct();
        end
        
        % This is where you put the data you want to graph.
        %   XData = The data for the x-axis
        %   YData = The data for the y-axis
        % eg. the parent function graphs the responses plot(XData,YData);
        %
        % Note: If wither value is empty, it will not graph the function.        
        function [XData , YData] = response(obj, protocolPlugin, epoch, amp, dbScalingFactor) 
            if isempty(amp)
                % Use the first device response found if no device name is specified.
                [responseData, sampleRate, units] = epoch.response();
            else
                [responseData, sampleRate, units] = epoch.response(amp);
            end
                
            % Get the parameters for this "class" of epoch.
            % An epoch class is defined by a set of parameter values.
            if isempty(obj.meanParamNames)
                % Automatically detect the set of parameters.
                epochParams = protocolPlugin.epochSpecificParameters(epoch);
            else
                % The protocol has specified which parameters to use.
                for i = 1:length(obj.meanParamNames)
                    epochParams.(obj.meanParamNames{i}) = epoch.getParameter(obj.meanParamNames{i});
                end
            end
            
            % Check if we have existing data for this class of epoch.
            meanPlot = struct([]);
            for i = 1:numel(obj.meanPlots)
                if isequal(obj.meanPlots(i).params, epochParams)
                    meanPlot = obj.meanPlots(i);
                    break;
                end
            end
           
            if isempty(meanPlot)
                % This is the first epoch of this class to be plotted.
                meanPlot = {};
                meanPlot.params = epochParams;
                meanPlot.data = responseData;
                meanPlot.sampleRate = sampleRate;
                meanPlot.units = units;
                meanPlot.count = 1;
                
                % for normal average, uncomment
%                 XData = (1:length(meanPlot.data)) / sampleRate;
%                 YData = meanPlot.data;

                % for normal average, comment
                XData = [];
                YData = [];
                
                obj.meanPlots(end + 1) = meanPlot;
            else
                % for normal average, comment                
                XData = (1:length(meanPlot.data)) / sampleRate;
                YData = meanPlot.data * dbScalingFactor;
                
                meanPlot.data = (meanPlot.data * meanPlot.count + responseData) / (meanPlot.count + 1);
                meanPlot.count = meanPlot.count + 1;

                % for normal average, uncomment                
%                 XData = (1:length(meanPlot.data)) / sampleRate;
%                 YData = meanPlot.data;
                                
                obj.meanPlots(i) = meanPlot;
            end
            
            if obj.canSave
                obj.lastPlot.XData = (1:length(meanPlot.data)) / sampleRate;
                obj.lastPlot.YData = meanPlot.data;
            end
        end
    end
end

