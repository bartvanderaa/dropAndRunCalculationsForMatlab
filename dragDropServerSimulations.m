%*******************************************************************************
% dragDropServerSimulations.m
%*******************************************************************************
%
% Algorithm details:
% - Drag-and-drop .m-file calculation scripts into a serial server session, e.g. on a remote Linux server with a local SSH (screen) session.
% - The overhead script continuously looks for new excecutable scripts, and runs them if new files are found.
% - The oldest files in the folder are computed first.
% - A three-stage folder structure (toBeProcessed, processing, processed) is used to avoid infinite excecution.
% - Excecutable m-files are written as usual, but storage of the .mat-file is done according to, e.g. savePath = fileparts(pwd); save([savePath '/mat/solutions.mat']);
% - Avoid using clear-statements in the excecutable scripts, otherwise the folder-structure is deleted too.
%
% Update log:
% 2014-07-28: initial version created;
% 2014-08-20: rewritten as a function;
%
%*******************************************************************************
% Bart van der Aa
% Division of Applied Acoustics
% Chalmers University of Technology
% www.ta.chalmers.se
% info@bartvanderaa.com

function dragDropServerSimulations(rootpath, toBeProcessedPath, processingPath, processedPath)

% Add all subfolders located one level up from the root level
addpath(genpath(fileparts(rootpath)));

if nargin == 1
    toBeProcessedPath = [rootpath '/toBeProcessed/'];
    processingPath = [rootpath '/processing/'];
    processedPath = [rootpath '/processed/'];
elseif nargin>1 && nargin ~= 4
    error('All paths must be specified correctly, i.e. the "toBeProcessedPath", "processingPath" and "processedPath".')
end

%============================================================
% start loop
%============================================================
mainSession = true;
while mainSession
    
    %************************************************************
    % Open folder
    %************************************************************
    
    % Select all .mat-files stored in toBeProcessed
    selectFiles = fullfile(toBeProcessedPath, '*.m');
    % Dir all *.mat files in predefined folder
    filesDir = dir(selectFiles);
    
    %************************************************************
    % Find oldest calculation file in the folder
    %************************************************************
    
    dateVec = [filesDir.datenum];
    [~, oldestFile] = min(dateVec);
    
    % No calculations are found in the folder... Search for new calculation files every 10 seconds instead, with a maximum of 7 days.
    if isempty(oldestFile)
        
        subSession = true;
        startStopWatch = tic;
        while subSession
            
            % Select all .mat-files stored in toBeProcessedPath
            selectFiles = fullfile(toBeProcessedPath, '*.m');
            % Dir all *.mat files in predefined folder
            filesDir = dir(selectFiles);
            % Find oldest calculation file in the folder
            dateVec = [filesDir.datenum];
            [~, oldestFile] = min(dateVec);
            
            % Stop loop when new file is found, or when 7 days (604800 s) have passed.
            stopWatch = toc(startStopWatch);
            if isempty(oldestFile)==0
                subSession = false;
            elseif stopWatch > 604800
                subSession = false;
                mainSession = false;
                sprintf('The server session stopped after 604800 s.')
            end
            sprintf(['I am waiting already for ' num2str(stopWatch) ' seconds since my last job. Please feed me!'])
            % Pause for 10 seconds.
            pause(10)
            
        end
    else
        %************************************************************
        % Grab file, move, and compute
        %************************************************************
        
        % Grab file and move to the "../processing" folder
        grabbedFile = filesDir(oldestFile).name;
        movefile(fullfile(toBeProcessedPath, grabbedFile), fullfile(processingPath, grabbedFile));
        % Run file
        run(fullfile(processingPath, grabbedFile));
        % Move the excecuted script to the "../processed" folder
        movefile(fullfile(processingPath, grabbedFile), fullfile(processedPath, grabbedFile));
    end
end
