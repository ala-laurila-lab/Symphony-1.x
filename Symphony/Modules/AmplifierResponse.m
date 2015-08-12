classdef AmplifierResponse < Module
	
	properties(Constant)
		displayName = 'Amplifier Response'
	end

	properties(Access = private)
		infoLayout
        amplifierRespGraphView
        amplifierRespControlView
        amplifierRespController
        amplifierRespModel
	end


	methods

		function obj = AmplifierResponse(symphonyUI)
			obj = obj@Module(symphonyUI);
			obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);

			rigConfig = obj.symphonyUI.rigConfig;
			obj.amplifierRespModel = model.AmplifierRespModel;
            obj.amplifierRespController = controller.AmplifierRespController(rigConfig);
            obj.amplifierRespController.init(obj.amplifierRespModel);

            obj.createView();
		end
        
        function createView(obj)
        	set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            layout = uiextras.VBox(...
                'Parent', obj.figureHandle);
            obj.infoLayout = uiextras.HBox('Parent', layout);
            
            obj.amplifierRespGraphView = view.AmplifierRespGraphView(obj.amplifierRespModel, obj.amplifierRespController, layout);
            obj.amplifierRespControlView = view.AmplifierRespControlView(obj.amplifierRespModel, obj.amplifierRespController, layout);
            
            set(layout, 'Sizes', [-0.5 -5 120]);
        end

        function handleEpoch(obj, epoch)
            graphView = obj.amplifierRespGraphView;
            graphView.plotGraph(epoch);
        end

        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end
	end
end