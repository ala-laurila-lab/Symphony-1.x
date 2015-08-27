classdef TestView  < handle
    
    properties(Access = private)
        figureHandle
    end

    methods
        
        function obj = TestView()
            obj.figureHandle = figure( ...
                'Name', 'Graphical Amplifier Response', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'NumberTitle', 'off' );
            set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
        end
        
        function testAmpRespView(obj)
            v = view.AmpRespView(obj.figureHandle);
            c = controller.AmpRespController([], v);
            c.init();
            c.show({'ch1', 'ch2'})
        end
    end
end
    
