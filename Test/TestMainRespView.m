classdef TestMainRespView  < handle
    %AMPLIFIERRESPONSEVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        presenter
    end
    
    properties(Access = private)
        figureHandle
    end
    
    methods
        
        function obj = TestMainRespView()
            obj.figureHandle = figure( ...
                'Name', 'Graphical Amplifier Response', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off' );
            app = MockRigConfig();
            s = service.GraphingService(app.multiClampDeviceNames);
            v = view.MainGraphView(obj.figureHandle);
            obj.presenter = presenter.MainGraphPresenter(s, v);
            obj.presenter.go();
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

