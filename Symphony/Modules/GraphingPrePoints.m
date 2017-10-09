classdef GraphingPrePoints < Module
    %GRAPHING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        displayName = 'Graphing Pre Points'
        varianceColor = 'yellow'
        meanColor = 'white'
        axesBackgroundColor = 'black'
        BackgroundColor = [0.35 0.35 0.35];
        pointSize = 50
        lineWidth = 1        
    end
    
    properties
        epochNumber = 0
        prevMeanY
        prevVarianceY
        varAxes
        meanAxes
        amp
        previousPersistorPath
        validEpochNumbers 
        linePlot
    end
    
    methods
        function obj = GraphingPrePoints(symphonyUI)
            obj = obj@Module(symphonyUI);
            obj.createUI();
            obj.initGraph();
            obj.amp = obj.symphonyUI.protocol.amp;
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
        end
        
        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end

        %% GUI Functions
        function createUI(obj)
            %Construcing the GUI
            clf(obj.figureHandle);
            
            figureWidth = 600;
            figureHeight = 700;
            
            position = get(obj.figureHandle, 'Position');
            position(3) = figureWidth;
            position(4) = figureHeight;
            set(obj.figureHandle, 'Position', position);
            
            set(obj.figureHandle, 'Color', obj.BackgroundColor);
            set(obj.figureHandle, 'Menubar', 'figure');
        end
        
        %% Graph Functions
        function initGraph(obj)
            obj.varAxes = axes('Parent',obj.figureHandle,'XAxisLocation','bottom', 'YAxisLocation','left','YColor',obj.varianceColor,'XColor',obj.varianceColor);
            ylabel(obj.varAxes, 'Variance');
            axis(obj.varAxes,'tight');
            
            obj.meanAxes = axes('Parent',obj.figureHandle,'XAxisLocation','top', 'YAxisLocation','right','YColor',obj.meanColor,'XColor',obj.meanColor);
            ylabel(obj.meanAxes, 'Mean');
            axis(obj.meanAxes,'tight');
            
            set(obj.varAxes,'Color',obj.axesBackgroundColor);
            set(obj.meanAxes,'Color','none');
            obj.linePlot = false; 

        end
        
        function clearFigure(obj)
            obj.epochNumber = 0;
            obj.prevMeanY = 0;
            obj.prevVarianceY = 0;
            cla(obj.meanAxes);
            cla(obj.varAxes);
            obj.linePlot = false; 
            obj.previousPersistorPath = obj.symphonyUI.persistPath;
        end
        
        function tf = isNewCell(obj)
            tf = ~ isempty(obj.previousPersistorPath) && ~ strcmp(obj.previousPersistorPath, obj.symphonyUI.persistPath);
          
            if isempty(obj.previousPersistorPath) && ~ isempty(obj.symphonyUI.persistPath)
                obj.previousPersistorPath = obj.symphonyUI.persistPath;
            end
        end
        
        function handleEpoch(obj, epoch)
 
            
            obj.epochNumber = obj.epochNumber + 1;
            if strcmp(epoch.parameters.ampMode, 'Cell attached')
                obj.linePlot = false;
                return;
            end
            [responseData, ~, ~] = epoch.response(obj.amp);
            
            prePts = round(epoch.parameters.preTime / 1e3 * epoch.parameters.sampleRate);
            preResponsePoints = responseData(1:prePts);
             
            prePointMean = mean(preResponsePoints);
            prePointVariance = var(preResponsePoints);
            
            axis(obj.meanAxes,'tight');
            hold(obj.meanAxes, 'all');
            
            axis(obj.varAxes,'tight');
            hold(obj.varAxes, 'all');
            
            scatter(obj.meanAxes,obj.epochNumber, prePointMean, obj.pointSize, obj.meanColor, 'fill');
            scatter(obj.varAxes,obj.epochNumber, prePointVariance, obj.pointSize, obj.varianceColor, 'fill');

            if obj.linePlot
               plot(obj.meanAxes,[(obj.epochNumber-1) obj.epochNumber],[obj.prevMeanY prePointMean],'Color',obj.meanColor, 'LineWidth',obj.lineWidth,'DisplayName','Prepoint Mean - Line');              
               plot(obj.varAxes,[(obj.epochNumber-1) obj.epochNumber],[obj.prevVarianceY prePointVariance],'Color',obj.varianceColor, 'LineWidth',obj.lineWidth,'DisplayName','Prepoint Variance - Line');
            end

            set(obj.varAxes,'Color',obj.axesBackgroundColor);
            set(obj.meanAxes,'Color','none');
            hold(obj.varAxes, 'off');
            hold(obj.meanAxes, 'off');

            obj.prevMeanY = prePointMean;
            obj.prevVarianceY = prePointVariance;
            obj.linePlot = true;
        end        
    end
    
end

