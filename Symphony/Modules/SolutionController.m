classdef SolutionController < Module
    %SOLUTIONCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        displayName = 'Solution Controller'
    end
    
    properties
        port
        channels
        controls
        channelCode
        BytesAvailable
        conn = []
        color
        
        appStatusCells = {};
        readControlCells = {};
    end
    
    properties (Constant)
        defaultChannels = 5
    end
    
    methods
        function obj = SolutionController(symphonyUI)
            obj = obj@Module(symphonyUI);
            
            obj.setChannels();
            obj.calcChannelCodes();
            obj.createUI();
            obj.symphonyUI.protocol.moduleRegister(obj.displayName, obj);
        end
        
        function close(obj)
            if ~isempty(obj.conn) && strcmp(obj.conn.Status, 'open')
                fclose(obj.conn);
            end
            
            obj.symphonyUI.protocol.moduleUnRegister(obj.displayName);
            
            obj.conn = [];
            close@Module(obj);
        end    

        %% GUI Functions
        
        function createUI(obj)
            %Construcing the GUI
            clf(obj.figureHandle);
            
            smallPanelWidth = 75;
            panelWidth = 150;
            
            figureWidth = panelWidth + 2 * smallPanelWidth;
            figureHeight = obj.channels * 35;
            
            position = get(obj.figureHandle, 'Position');
            position(3) = figureWidth;
            position(4) = figureHeight;
            set(obj.figureHandle, 'Position', position);
            
            set(obj.figureHandle, 'Resize', 'off');
            
            %Variables Used for placing objects on the GUI
            fLI = 5;
            sLI = 75;
            FontSize = 9;
            HeadingFontSize = 10;
            objectHeight = 30;
            objectWidth = 65;
            
            obj.color = get(obj.figureHandle, 'Color');
            
            obj.controls = struct();
                        
            % The Panel to control the valves
            panelParamTag = 'ValveControl';
            obj.controls.(panelParamTag) = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [0 0 panelWidth figureHeight] ...
                );
            
            for v = 1:obj.channels
                
                sPanelParamTag = ['valve' obj.channelCode(v)];
                obj.controls.(sPanelParamTag) = uipanel(...
                    'Parent', obj.controls.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Title', v, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((figureHeight - 15) - ((v) * (((figureHeight - 15)/obj.channels)))) 145 (figureHeight/obj.channels)] ...
                    );
                
                paramTag = ['Open' obj.channelCode(v)];
                obj.controls.(paramTag) = uicontrol(...
                    'Parent', obj.controls.(sPanelParamTag), ...
                    'Units', 'points', ...
                    'Enable', 'Off', ...
                    'Position', [fLI 3 objectWidth 20], ...
                    'Callback',   @(hObject,eventdata)openClose(obj, hObject,eventdata,v, 1), ...
                    'String', 'Open', ...
                    'Tag', paramTag);
                
                paramTag = ['Close' obj.channelCode(v)];
                obj.controls.(paramTag) = uicontrol(...
                    'Parent', obj.controls.(sPanelParamTag), ...
                    'Units', 'points', ...
                    'Enable', 'Off', ...
                    'Position', [sLI 3 objectWidth 20], ...
                    'Callback',  @(hObject,eventdata)openClose(obj, hObject,eventdata,v, 0), ...
                    'String', 'Close', ...
                    'Tag', paramTag);
            end
            
            % The Panel Display the Valve Status
            panelParamTag = 'ValveStatus';
            obj.controls.(panelParamTag) = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [panelWidth 0 smallPanelWidth figureHeight] ...
                );
            
            for v = 1:obj.channels
                sPanelParamTag = [panelParamTag obj.channelCode(v)];
                obj.controls.(sPanelParamTag) = uipanel(...
                    'Parent', obj.controls.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((figureHeight - 15) - ((v) * (((figureHeight - 15)/obj.channels)))) smallPanelWidth-5 ((figureHeight/obj.channels) - 6)] ...
                    );
            end
            
            % The Panel Display the Valve Status
            panelParamTag = 'ValveControl';
            obj.controls.(panelParamTag) = uipanel(...
                'Parent', obj.figureHandle, ...
                'Units', 'points', ...
                'FontSize', HeadingFontSize, ...
                'Title', panelParamTag, ...
                'Tag', panelParamTag, ...
                'Position', [(smallPanelWidth + panelWidth) 0 smallPanelWidth figureHeight] ...
                );
            
            for v = 1:obj.channels
                sPanelParamTag = [panelParamTag obj.channelCode(v)];
                obj.controls.(sPanelParamTag) = uipanel(...
                    'Parent', obj.controls.(panelParamTag), ...
                    'Units', 'points', ...
                    'FontSize', FontSize, ...
                    'Tag', sPanelParamTag, ...
                    'Position', [1 ((figureHeight - 15) - ((v) * (((figureHeight - 15)/obj.channels)))) smallPanelWidth - 5 ((figureHeight/obj.channels) - 6)] ...
                    );
                
                paramTag = ['PortsLabel' obj.channelCode(v)];
                obj.controls.(paramTag) = uicontrol(...
                    'Parent', obj.controls.(sPanelParamTag), ...
                    'Style', 'text', ...
                    'String', '', ...
                    'Units', 'points', ...
                    'Position', [5 (FontSize - 6) smallPanelWidth - 25 objectHeight/2], ...
                    'FontSize', FontSize, ...
                    'Tag', paramTag);
                
            end
            
            obj.controls.menu = obj.createMenu();
            
            set(obj.controls.menu.file.disconnect, 'Enable', 'Off');
            set(obj.controls.menu.file.connect, 'Enable', 'On');
        end
        
        function menu = createMenu(obj)
            menu = struct();
            menu.file = struct();
            
            menu.file.parent = uimenu(obj.figureHandle,'Label','File');
            menu.file.connect = uimenu(menu.file.parent,'Label','Connect','Accelerator','n','Callback',@(hObject,eventdata)connect(obj,hObject,eventdata));
            menu.file.disconnect = uimenu(menu.file.parent,'Label','Disconnect','Accelerator','c','Callback',@(hObject,eventdata)disconnect(obj,hObject,eventdata));
            menu.file.changeChannels = uimenu(menu.file.parent,'Label','Amount of Channels','Accelerator','u','Callback',@(hObject,eventdata)userInputChannelsFcn(obj,hObject,eventdata));
            menu.file.updateGui = uimenu(menu.file.parent,'Label','Update GUI','Accelerator','5','Callback',@(hObject,eventdata)valveStatus(obj,hObject,eventdata));
        end
        
        %% Channel Functions
        function calcChannelCodes(obj)
            upperCaseStart = 65;
            alphabetLength = 26;
            lowerCaseStart = 97;
            
            for v = 1:obj.channels
                if v < (alphabetLength + 1)
                    indexnum = v - 1;
                    number = upperCaseStart;
                else
                    indexnum = v - 1 - alphabetLength;
                    number = lowerCaseStart;
                end
                
                obj.channelCode(v) = char(number + indexnum);
            end
        end
        
        function setChannels(obj)
            if ispref('Symphony', 'Solution_Controller_Channels') && uint32(getpref('Symphony', 'Solution_Controller_Channels', 0)) > 0
                obj.channels = getpref('Symphony', 'Solution_Controller_Channels');
            else
                if isempty(obj.channels)
                    obj.userInputChannels();
                end
            end
        end
        
        function userInputChannels(obj)
            answer = inputdlg({'Enter the amount of channels in the Solution Controller:'}, 'Channels', [1 50], { char(obj.defaultChannels) });
            if isempty(answer)
                obj.channels = obj.defaultChannels;
            else
                obj.channels = uint32(str2double(answer{1}));
                setpref('Symphony', 'Solution_Controller_Channels', obj.channels);
            end
            
            obj.appStatusCells = {cell(obj.channels + 1,1)};
            obj.readControlCells = {cell(obj.channels + 1,1)};
        end
        
        function userInputChannelsFcn(obj, ~, ~)
            obj.disconnect();
            obj.userInputChannels();
            obj.calcChannelCodes();
            obj.createUI();
            
            if ~isempty(obj.conn) && strcmp(obj.conn.Status, 'closed')
                obj.connect();
            end
        end
        
        function valveStatus( obj , ~ , ~ )
            try
                if strcmp(obj.conn.Status, 'open')
                                        
                    appStatusCellsTemp = textscan(obj.status('S'), '%s', 'delimiter', sprintf(','));
                    obj.flush();
                    readControlCellsTemp = textscan(obj.status('C'), '%s', 'delimiter', sprintf(','));
                    obj.flush();

                    for v = 1:obj.channels
                        change = false;
                        if ~strcmp(obj.appStatusCells{1}{v+1},appStatusCellsTemp{1}{v+1})
                            obj.appStatusCells{1}{v+1} = appStatusCellsTemp{1}{v+1};
                            change = true;
                        end
                        
                        if ~strcmp(obj.readControlCells{1}{v+1},readControlCellsTemp{1}{v+1})
                            obj.readControlCells{1}{v+1} = readControlCellsTemp{1}{v+1};
                            change = true;
                        end
                        
                        if change
                            obj.changeValveStatus(v, str2double(obj.appStatusCells{1}{v+1}), str2double(obj.readControlCells{1}{v+1}));
                        end
                    end
                
                end
            catch %#ok<CTCH>
            end
        end
        
        function status = getStatus(obj)            
            obj.valveStatus();
            status = obj.appStatusCells;
        end
        
        function openClose(obj, ~ , ~ , v, s)
            obj.appStatusCells{1}{v+1} = num2str(s);
            obj.changeValveStatus(v, str2double(obj.appStatusCells{1}{v+1}), str2double(obj.readControlCells{1}{v+1}));
            msg = ['V,' int2str(v) ',' int2str(s)];
            obj.send(msg);
            obj.flush();
        end
        
        
        % A function to change the status of the valve in the GUI
        function changeValveStatus(obj, valve, status, control)
            name = obj.channelCode(valve);
            
            onBtn = '';
            offBtn = '';
            
            % status values:
            % 0 = Off
            % 1 = On
            % 2 = Overloaded
            % 3 = Disconnecting From the App. (ie. No Color Marker)
            
            switch status
                case 0
                    c = [1 0 0];
                    onBtn = 'On';
                    offBtn = 'Off';
                case 1
                    onBtn = 'Off';
                    offBtn = 'On';
                    c = [0 1 0];
                case 2
                    %To Do
                case 3
                    c = obj.color;
                    onBtn = 'Off';
                    offBtn = 'Off';
                    app = '';
            end
            
            
            % status values:
            % 0 = Front panel switch
            % 1 = On
            % 2 = Remote switch
            
            if status ~= 3
                switch control
                    case 0
                        onBtn = 'Off';
                        offBtn = 'Off';
                        app = 'Remote';
                    case 1
                        app = 'Computer';
                    case 2
                        onBtn = 'Off';
                        offBtn = 'Off';
                        app = 'Remote';
                end
            end
            
            if ~isempty(onBtn)
                label = ['Open' name];
                set(obj.controls.(label), 'Enable', onBtn);
            end
            
            if ~isempty(offBtn)
                label = ['Close' name];
                set(obj.controls.(label), 'Enable', offBtn);
            end
            
            label = ['PortsLabel' name];
            set(obj.controls.(label), 'String', app);
            
            label = ['ValveStatus' name];
            set(obj.controls.(label), 'BackgroundColor', c);            
        end
        
        %% COM Port
        function send(obj, msg)
            fprintf(obj.conn,msg);
        end
        
        function flush(obj)
            if obj.conn.BytesAvailable > 0
                fread(obj.conn, obj.conn.BytesAvailable)
            end
        end
        
        function status = status(obj, msg)
            obj.send(msg);
            status = fscanf(obj.conn);
        end
        
        function disconnect(obj, ~, ~)
            if ~isempty(obj.conn) && strcmp(obj.conn.Status, 'open')
                fclose(obj.conn);

                set(obj.controls.menu.file.disconnect, 'Enable', 'Off');
                set(obj.controls.menu.file.connect, 'Enable', 'On');

                for v = 1:obj.channels
                    obj.changeValveStatus(v, 3, 3);
                end
            end
        end
        
        function connect(obj, ~, ~)
            if isempty(obj.conn)               
                serialInfo = instrhwinfo('serial');
                portList = serialInfo.AvailableSerialPorts;
                for p = 1:numel(portList)
                    obj.conn = serial(portList{p});
                    obj.conn.BaudRate = 57600;
                    obj.conn.ReadAsyncMode = 'continuous';
                    obj.conn.Terminator = 'LF/CR';

                    fopen(obj.conn);
                    
                    try
                        if isempty(obj.status('S'));
                            fclose(obj.conn);
                            if p==numel(portList)
                                obj.disconnect;
                            end
                        else
                            break;                           
                        end
                    catch
                        fclose(obj.conn);
                    end
                end
            elseif strcmp(obj.conn.Status, 'closed')
                fopen(obj.conn);
            end

            set(obj.controls.menu.file.disconnect, 'Enable', 'On');
            set(obj.controls.menu.file.connect, 'Enable', 'Off');

            obj.appStatusCells = {cell(obj.channels + 1,1)};
            obj.readControlCells = {cell(obj.channels + 1,1)};

            obj.valveStatus();
        end
        
    end
end

