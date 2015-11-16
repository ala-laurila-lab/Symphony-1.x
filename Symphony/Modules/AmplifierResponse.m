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
            obj.createView();
        end
        
        function createView(obj)
            rigConfig = obj.symphonyUI.rigConfig;
            s = service.GraphingService(rigConfig.multiClampDeviceNames);
            s.protocol = obj.symphonyUI.protocol;
            v = views.MainGraphView(obj.figureHandle);
            obj.presenter = presenters.MainGraphPresenter(s, v);
            obj.presenter.go();
        end
        
        function handleEpoch(obj, epoch)           
            obj.presenter.plotGraph(epoch);
        end
        
        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end
        
        function delete(obj)
            if ~isempty(obj.figureHandle)
                % Remember the window position.
                setpref('Symphony', [class(obj) '_Position'], get(obj.figureHandle, 'Position'));
                obj.figureHandle = [];
            end
        end
    end
end