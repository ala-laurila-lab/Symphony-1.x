classdef AmplifierResponse < Module
    
    properties(Constant)
        displayName = 'Amplifier Response'
    end
    
    properties(Access = private)
        presenter
    end
    
    
    methods
        
        function obj = AmplifierResponse(symphonyUI)
            obj = obj@Module(symphonyUI);
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
            obj.createView
        end
        
        function createView(obj)
            rigConfig = obj.symphonyUI.rigConfig;
            set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            
            model = model.GraphingService(rigConfig.multiClampDeviceNames);
            view = view.AmpRespView(obj.figureHandle);
            obj.presenter = presenter.AmpRespPresenter(model, view);
            
            obj.presenter.init
            obj.presenter.show
        end
        
        function handleEpoch(obj, epoch)
            obj.presenter.plotGraph(epoch);
        end
        
        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end
    end
end