classdef NDFConfiguration  < Module
    
    properties(Constant)
        displayName = 'NDFConfiguration'
    end
    
    properties
        selectedNdfsMap
        filterWheelsMap
        currentNdfTextMap
        wheelconfigs
        ndfButtonMap
    end
    
    methods
        
        function obj = NDFConfiguration(symphonyUI)
            obj = obj@Module(symphonyUI);
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
            obj.createUi();
        end
        
        function close(obj)
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            close@Module(obj)
        end
        
        function setFilterWheelNDF(obj, h, ~)
            key = get(h, 'Tag');
            ndf = obj.viewSelectedNdf(key);
            wheel = obj.filterWheelsMap(key);
            wheel.setNDF(ndf);
            obj.updateCurrentNdfText(key);
        end
        
        function ndf = viewSelectedNdf(obj, wheelConfig)
            
            if ~ischar(wheelConfig)
                wheelConfig = char(wheelConfig);
            end
            idx = get(obj.selectedNdfsMap(wheelConfig), 'Value');
            ndfs = get(obj.selectedNdfsMap(wheelConfig), 'String');
            ndf = ndfs(idx);
        end
        
        
        function viewNDFSetButton(obj, tf)
            k = obj.ndfButtonMap.keys();
            for i = 1:numel(k)
                set(obj.ndfButtonMap(k{i}), 'Enable', util.onOff(tf));
            end
        end
        
        function updateCurrentNdfText(obj, wheelConfig)
            if ~ischar(wheelConfig)
                wheelConfig = char(wheelConfig);
            end
            wheel = obj.filterWheelsMap(wheelConfig);
            set(obj.currentNdfTextMap(wheelConfig), 'String', strcat('Current density -', wheel.getNDF()));
        end
        
        function createUi(obj)
            
            rigConfig = obj.symphonyUI.rigConfig;
            obj.filterWheelsMap = rigConfig.filterWheels;
            obj.wheelconfigs = FilterWheelConfig.listByRigName(rigConfig.RIG_NAME);
            n = numel(obj.wheelconfigs);
            
            set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
            set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            
            layout = uiextras.VBox('Parent', obj.figureHandle);
            uicontrol(...,
                'Parent', layout,...
                'Style','text',...
                'String', sprintf('NDF configuration - %s', rigConfig.RIG_DESC));
            
            dynamicControls = uiextras.Grid(...
                'Parent', layout,...
                'Padding', 5, 'Spacing', 2);
            
            
            obj.currentNdfTextMap = containers.Map();
            obj.selectedNdfsMap =  containers.Map();
            
            for i = 1:n
                config = obj.wheelconfigs(i);
                key = char(config);
                wheel = obj.filterWheelsMap(key);
                lastNdf = wheel.getNDF();
                ndfs = config.ndfContainer.keys;
                
                pannel = uiextras.VBox('Parent', dynamicControls);
                uicontrol(...,
                    'HorizontalAlignment', 'left',...
                    'Parent', pannel,...
                    'Style','text',...
                    'String', sprintf('Filter wheel - %s',config.wheelName));
                
                if isempty(lastNdf)
                    ndfText = 'current density - NA';
                else
                    ndfText = strcat('Current density - ', lastNdf);
                end
                
                obj.currentNdfTextMap(key)= uicontrol(...,
                    'HorizontalAlignment', 'left',...
                    'Parent', pannel,...
                    'Style','text',...
                    'String', ndfText);
                ndfLayout = uiextras.HBox('Parent', pannel);
                uicontrol(...,
                    'HorizontalAlignment', 'left',...
                    'Parent', ndfLayout,...
                    'Style','text',...
                    'String', 'Move To');
                
                obj.selectedNdfsMap(key) = uicontrol(...,
                    'Parent', ndfLayout,...
                    'Style', 'popup',...
                    'HorizontalAlignment', 'left',...
                    'String', ndfs);
                
                if ~ isempty(lastNdf)
                    set(obj.selectedNdfsMap(key), 'Value', find(cellfun(@(ndf) strcmp(ndf,lastNdf), ndfs)==1));
                end
                
                buttonTxt = 'SET';
                if ~ config.motorized
                    buttonTxt = 'SET MANUAL';
                end
                button = uiextras.HButtonBox( 'Parent', pannel, 'ButtonSize', [100 20]);
                obj.ndfButtonMap(key) = uicontrol(...,
                    'String', buttonTxt,...
                    'Parent', button,...
                    'Tag', key,...
                    'callback',@(h, d)setFilterWheelNDF(obj, h, d));
                set(pannel, 'Sizes', [30, 30, 30, 30]);
            end
            set(dynamicControls, 'ColumnSizes', [200, 200]);
            set(layout, 'Sizes', [20, -1]);
        end
    end
end

