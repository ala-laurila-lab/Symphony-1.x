classdef TestAmpRespView  < handle
    %AMPLIFIERRESPONSEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        presenter
    end
    
    properties(Access = private)
        figureHandle
    end
    
    events
        plotSpikeStats
    end
    
    methods
        
        function obj = TestAmpRespView()
            obj.figureHandle = figure( ...
                'Name', 'Graphical Amplifier Response', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off' );
            set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            app = MockRigConfig;
            model = model.AmpRespModel(app.multiClampDeviceNames);
            view = view.AmpRespView(obj.figureHandle);
            obj.presenter = presenter.AmpRespPresenter(model, view);
            obj.presenter.init
            obj.presenter.show
        end
        
         function handleEpoch(obj, epoch)
            try
             obj.presenter.plotGraph(epoch);
            epoch.nextIndex;
            catch
                disp('[Amplifier response] something wrong happend ..')
            end
         end
        
         function run(obj, n)
             e = MockEpoch;
             e.index = 21;
             for i = 1:n 
                 obj.handleEpoch(e);pause(1); 
             end
         end
    end
end

