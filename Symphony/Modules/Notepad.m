classdef Notepad < Module
    %NOTEPAD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        displayName = 'Notepad'
    end
    
    properties
        directory
        headers
        isLogging = true
        currentFileName 
        runningEpochNumber = 0
        relativeEpochTime
    end
    
    properties (Constant, Hidden)
        timeString = 'yymmdd';
    end
    
    properties (Hidden)
        dateStamp
        controls
        previousPersistorPath
        firstEpochStartTime
        userInterfaceEnabled = true
    end
    
    methods
        
        function obj = Notepad(symphonyUI)
            obj = obj@Module(symphonyUI);
            
            obj.directory = fullfile(regexprep(userpath, ';', ''), 'Symphony', 'Logs');
            obj.headers = fullfile(regexprep(userpath, ';', ''), 'Symphony', 'Headers');
            
            obj.createUI();
            obj.newFcn();
            

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
            figureHeight = 350;
            
            position = get(obj.figureHandle, 'Position');
            position(3) = figureWidth;
            position(4) = figureHeight;
            
            set(obj.figureHandle, 'Position', position);  
            set(obj.figureHandle, 'Resize', 'on');
            set(obj.figureHandle, 'Visible', 'on');
           
                          
            obj.controls = struct();
            obj.controls.textArea = uicontrol(...
               'Parent',obj.figureHandle,...
               'BackgroundColor',[1 1 1],...
                'FontSize', 8,...
                'Units','points',...
                'Enable','off',...
                'HorizontalAlignment','left',...
                'Max',1000,...
                'Position',[0 0 figureWidth figureHeight],...
                'Min',1,...
                'Style','edit',...
                'Tag','textArea');

            obj.controls.jScrollPanel = findjobj(obj.controls.textArea);

            try
                obj.controls.jScrollPanel.setVerticalScrollBarPolicy(obj.controls.jScrollPanel.java.VERTICAL_SCROLLBAR_AS_NEEDED);
                obj.controls.jScrollPanel = obj.controls.jScrollPanel.getViewport();
            catch 
                % may possibly already be the viewport, depending on release/platform etc.
            end

            obj.controls.jEditbox = handle(obj.controls.jScrollPanel.getView, 'CallbackProperties');
            obj.controls.jEditbox.setEditable(true);

            obj.controls.menu = obj.createMenu();
        end
        
        function menu = createMenu(obj)
            menu = struct();
            menu.file = struct();
            menu.edit = struct();
            menu.comments = struct();
            
            menu.file.parent = uimenu(obj.figureHandle,'Label','File');
            menu.file.new = uimenu(menu.file.parent,'Label','New','Accelerator','n','Callback',@(hObject,eventdata)newFcn(obj,hObject,eventdata));
            menu.file.open = uimenu(menu.file.parent,'Label','Open','Accelerator','o','Callback',@(hObject,eventdata)openFcn(obj,hObject,eventdata));
            menu.file.save = uimenu(menu.file.parent,'Label','Save','Accelerator','s','Callback',@(hObject,eventdata)saveFcn(obj,hObject,eventdata));
            menu.file.saveAs = uimenu(menu.file.parent,'Label','Save As','Accelerator','s','Callback',@(hObject,eventdata)saveAsFcn(obj,hObject,eventdata));
            menu.file.pinToBottom = uimenu(menu.file.parent,'Label','Pin to the Bottom','Accelerator','p','Callback',@(hObject,eventdata)setCaretPosition(obj,hObject,eventdata));
            menu.file.continueLoggingMenu = uimenu(menu.file.parent,'Label','Pause');
            menu.file.loggingOn = uimenu(menu.file.continueLoggingMenu,'Label','Start Logging','Enable','off','Callback',@(hObject,eventdata)pauseLoggingFcn(obj,hObject,eventdata,1));
            menu.file.loggingOff = uimenu(menu.file.continueLoggingMenu,'Label','Stop Logging','Enable','on','Callback',@(hObject,eventdata)pauseLoggingFcn(obj,hObject,eventdata,0));
            
            menu.edit.parent = uimenu(obj.figureHandle,'Label','Edit');
            menu.edit.enable = uimenu(menu.edit.parent,'Label','Enable','Accelerator','e','Callback',@(hObject,eventdata)enableFcn(obj,hObject,eventdata));
            menu.edit.disable = uimenu(menu.edit.parent,'Label','Disable','Accelerator','d','Enable','Off', 'Callback',@(hObject,eventdata)disableFcn(obj,hObject,eventdata));
            
            menu.insert.parent = uimenu(obj.figureHandle,'Label','Insert');
            menu.insert.comments = uimenu(menu.insert.parent,'Label','Comments','Accelerator','i','Callback',@(hObject,eventdata)insertCommentsFcn(obj,hObject,eventdata));
            menu.insert.header = uimenu(menu.insert.parent,'Label','Log Header Template','Accelerator','l','Callback',@(hObject,eventdata)insertHeaderFcn(obj,hObject,eventdata));
        end
        
        function setCaretPosition(obj,~,~)                   
            javaTextAreaHandler = findjobj(obj.controls.textArea);
            javaTextArea = javaTextAreaHandler.getComponent(0).getComponent(0);
            javaTextArea.getCaret().setUpdatePolicy(2);
        end
        
        %% Menu Functions
        function insertCommentsFcn( obj , ~ , ~ )
            comment = inputdlg('Enter you Comment','Comments', [30 100]);
            
            if ~isempty(comment)
                commentBanner = sprintf('***************************************************');

                obj.log(commentBanner);
                obj.log(strcat(datestr(now, 'HH:MM:SS'), '- ',char(comment)));
                obj.log(commentBanner);

                obj.saveAsFcn();
            end
        end
        
        function insertHeaderFcn( obj , ~ , ~ )
            [filename, pathname] =  uigetfile({'*.log;*.txt','All Files'}, 'Log Header File', obj.headers);
            if filename ~= 0
                obj.headers = pathname;
                file = fullfile(pathname, filename);
                
                fileText = obj.parseFile(file);
                currentText = get(obj.controls.textArea, 'String');
                set(obj.controls.textArea, 'String', [fileText; currentText]);
                obj.saveAsFcn();
            end
        end
        
        function enableFcn( obj , ~ , ~ )
            set(obj.controls.menu.edit.enable, 'Enable', 'off');
            set(obj.controls.menu.edit.disable, 'Enable', 'on');
            set(obj.controls.textArea, 'Enable', 'on');
        end
        
        function disableFcn( obj , ~ , ~ )
            set(obj.controls.menu.edit.enable, 'Enable', 'on');
            set(obj.controls.menu.edit.disable, 'Enable', 'off');
            set(obj.controls.textArea, 'Enable', 'off');
        end
        
        function pauseLoggingFcn( obj , ~ , ~ , status )
            obj.isLogging = status;
            if  obj.isLogging 
                set(obj.controls.menu.file.loggingOn,'Enable', 'off');
                set(obj.controls.menu.file.loggingOff,'Enable', 'on');
            else
                set(obj.controls.menu.file.loggingOn,'Enable', 'on');
                set(obj.controls.menu.file.loggingOff,'Enable', 'off');
            end
        end
        
        function openFcn ( obj , ~ , ~ )
            [filename, pathname] =  uigetfile({'*.log;*.txt','All Files'}, 'New File', obj.directory);
            if filename ~= 0
                obj.openFile(pathname, filename);
            elseif isempty(obj.currentFileName)
                obj.changeUserInterfaceState(false);
            end
        end
                
        function newFcn( obj , ~ , ~ )
            temp = inputdlg('File Name:','File Name', [1 50], {[obj.getTimestamp() '-' obj.symphonyUI.rigConfig.displayName]});
            if ~isempty(temp)
                pathname = char(obj.directory);
                filename = [char(temp) '.log'];
                
                if exist(fullfile(pathname, filename), 'file')      
                    obj.openFile(pathname, filename);
                else
                    obj.currentFileName = strrep(temp, ' ', '-');
                    set(obj.controls.textArea, 'String', {''});
                    set(obj.figureHandle,  'Name', ['Notes File: ' char(obj.currentFileName)]);
                    obj.changeUserInterfaceState(true);      
                end
                
            elseif isempty(obj.currentFileName)
                    obj.changeUserInterfaceState(false);
            end
        end
        
        function saveFcn( obj , ~ , ~ )
            s = get(obj.controls.jEditbox, 'text');
            nRow = size(s,1);
                        
            file = fullfile(obj.directory, char(obj.currentFileName));
            
            extension = '.log';
            if isempty(strfind(file,extension))
                file = [file extension];
            end
            
            fid = fopen(file, 'w+');
            formatSpec = '%s%s\n';
            out = '';
            
            for iRow = 1:nRow
                out = sprintf(formatSpec,out,char(s(iRow,:)));
            end
            
            fprintf(fid, out);
            fclose(fid);
        end
        
        function saveAsFcn( obj , ~ , ~ )
            
                     
            if isempty(obj.currentFileName)
                [filename, pathname] =  uiputfile({'*.log;', 'log files'}, 'Save As', obj.directory);
            end
            
            if  isempty(obj.currentFileName) && filename ~= 0
                obj.directory = pathname;
                obj.currentFileName = filename;
                set(obj.figureHandle,  'Name', obj.currentFileName);
                obj.saveFcn();
            else
                obj.saveFcn();
            end
        end
        
        %% HELPER FUNCTIONS
        function openFile(obj, pathname, filename)
            file = fullfile(pathname, filename);
            fileText = obj.parseFile(file);
            obj.currentFileName = filename;
            set(obj.controls.textArea, 'String', fileText);
            set(obj.figureHandle,  'Name', ['Notes File: ' obj.currentFileName]);
            obj.changeUserInterfaceState(true);
            obj.directory = pathname;           
        end
        
        function changeUserInterfaceState(obj, enabled)
            if obj.userInterfaceEnabled ~= enabled
                
                if enabled
                    state = 'on';
                else
                    state = 'off';
                end
                
                set(obj.controls.menu.file.save, 'Enable', state);
                set(obj.controls.menu.file.saveAs, 'Enable', state);
                set(obj.controls.menu.file.continueLoggingMenu, 'Enable', state);
                set(obj.controls.menu.insert.comments, 'Enable', state);
                set(obj.controls.menu.insert.header, 'Enable', state);
                set(obj.controls.menu.edit.enable, 'Enable', state);
                
                if ~enabled
                    set(obj.controls.menu.edit.disable, 'Enable', state);
                end
                
                obj.userInterfaceEnabled = enabled;
            end
        end
        
        function  out = parseFile(~, fileString)
            fid = fopen(fileString, 'r');
            document = textscan(fid, '%s', 'Delimiter', '\n');
            fclose(fid);
            
            out = document{1};
        end
                
        function timestamp = getTimestamp(obj)
             timestamp = datestr(now, obj.timeString);
        end
        
        function updateRunningEpochNumber(obj, runningEpochTime)
            
            % ideally persistPath should not be empty, as logging file
            % enabled only after valid persistor
            
            if  isempty(obj.previousPersistorPath) || ~ strcmp(obj.previousPersistorPath, obj.symphonyUI.persistPath)
                obj.runningEpochNumber = 0;
                obj.previousPersistorPath = obj.symphonyUI.persistPath;
                obj.firstEpochStartTime = datetime(runningEpochTime, 'format', 'HH:mm:ss');
            end
            obj.runningEpochNumber = obj.runningEpochNumber + 1;
            obj.relativeEpochTime = seconds(datetime(runningEpochTime, 'format', 'HH:mm:ss') - obj.firstEpochStartTime);
        end
        
        %% Logging
        function log( obj, s )
            
           rows=size(s,1);
            for row=1:rows
                obj.controls.jEditbox.setCaretPosition(obj.controls.jEditbox.getDocument().getLength());
                obj.controls.jEditbox.replaceSelection(sprintf('%s \n', s(row,:)));
            end
        end
    end
end

