classdef AmplifierResponse < Module
    
    properties(Constant)
        displayName = 'Amplifier Response'
    end
    
    properties(Access = private)
        presenter
        graphingService
        analysisConfigurationMap
    end
    
    methods
        
        function obj = AmplifierResponse(symphonyUI)
            obj = obj@Module(symphonyUI);
            obj.analysisConfigurationMap = containers.Map();
            obj.analysisConfigurationMap('LEDFactorPulse') = 'service.LEDFactorPulseResponseStatistics';
            obj.analysisConfigurationMap('SinglePhoton') = 'service.SinglePhotonResponseStatistics';
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
            obj.createView();
        end
        
        function createView(obj)
            rigConfig = obj.symphonyUI.rigConfig;
            protocolClass = class(obj.symphonyUI.protocol);
            
            if ~ isKey(obj.analysisConfigurationMap, protocolClass)
                return;
            end
            s = service.GraphingService(rigConfig.multiClampDeviceNames, obj.analysisConfigurationMap(protocolClass));
            s.protocol = obj.symphonyUI.protocol;
            v = views.MainGraphView(obj.figureHandle);
            obj.presenter = presenters.MainGraphPresenter(s, v);
            obj.presenter.go();
            obj.graphingService = s;
        end
        
        function handleEpoch(obj, epoch)

            obj.graphingService.protocol = obj.symphonyUI.protocol;
            
            if obj.graphingService.hasProtocolChanged()
               protocolClass = class(obj.symphonyUI.protocol);
               
               if ~ isKey(obj.analysisConfigurationMap, protocolClass)
                   warning('No analysis configuration exist for protocol')
                   return;
               end
               obj.graphingService.initServiceContext(obj.analysisConfigurationMap(protocolClass));
            end
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