% These are the default configuration settings for Symphony. Do not modify this file directly.
%
% If you want to override some of the settings, create a symphonyrc function with the following format:
%
% function config = symphonyrc(config)
%
%     % Place all custom settings here...
%     % Follow the default symphonyrc file as a guide.
%
% end
%
% Save the function as symphonyrc.m in your MATLAB user path. You can find and set the location of your MATLAB user path 
% by using the userpath command in the MATLAB command window.

function config = symphonyrc(config)
    symphonyDir = fullfile(regexprep(userpath, ';', ''), 'Symphony');
    
    % Directory containing rig configurations.
    % Rig configuration .m files must be at the top level of this directory.
    config.rigConfigsDir = fullfile(symphonyDir, 'Rig Configurations', 'List');
    
    % Directory containing protocols.
    % Each protocol .m file must be contained within a directory of the same name as the protocol class itself.
    config.protocolsDir = fullfile(symphonyDir, 'Protocols');
    
    % Directory containing figure handlers (built-in figure handlers are always available).
    % Figure handler .m files must be at the top level of this directory.
    config.figureHandlersDir = '';
    
    % Directory containing modules (built-in modules are always available).
    % Module .m files must be at the top level of this directory.
    config.modulesDir = fullfile(symphonyDir, 'Modules');
    
    % Text file specifying the source hierarchy.
    config.sourcesFile = fullfile(symphonyDir, 'Source.txt');
    
    % Factories to define which DAQ controller and epoch persistor Symphony should use.
    % HekaDAQControllerFactory and EpochHDF5PersistorFactory are only supported on Windows.
    if ispc
        config.daqControllerFactory = HekaDAQControllerFactory();
        config.epochPersistorFactory = EpochHDF5PersistorFactory();
    else
        config.daqControllerFactory = SimulationDAQControllerFactory('LoopbackSimulation');
        config.epochPersistorFactory = EpochXMLPersistorFactory();
    end
end