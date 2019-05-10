%--------------------------------------------------------------------------
% INSTALL_gpopsUserInterp
% This scripts helps you get gpopsUserInterp up and running
%--------------------------------------------------------------------------
% Automatically adds project files to your MATLAB path, checks for a
% required file, and opens an example
%--------------------------------------------------------------------------
% Install script based on MFX Submission Install Utilities
% https://github.com/danielrherber/mfx-submission-install-utilities
% https://www.mathworks.com/matlabcentral/fileexchange/62651
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber (danielrherber)
% Link: https://github.com/danielrherber/gpops-user-interp
%--------------------------------------------------------------------------
function INSTALL_gpopsUserInterp(varargin)

    % intialize
    silentflag = 0; % don't be silent
    exampleflag = 1; % open an example

    % parse inputs
    if ~isempty(varargin)
        if any(strcmpi(varargin,'silent'))
            silentflag = 1; % be silent
        end
        if any(strcmpi(varargin,'no-example'))
            exampleflag = 0; % don't open the example
        end
    end

    % add contents to path
    RunSilent('AddSubmissionContents(mfilename)',silentflag)
    
	% gpopsLagrangeInterp check
    RunSilent('gpopsLagrangeInterpCheck',silentflag)

	% open an example
    if (~silentflag && exampleflag), OpenThisFile('GUIex_launch'); end

	% close this file
    RunSilent('CloseThisFile(mfilename)',silentflag)

end
%-------------------------------------------------------------------------- 
function gpopsLagrangeInterpCheck %#ok<DEFNU>
    disp('--- Checking for gpopsLagrangeInterp')
    
    % check if gpopsLagrangeInterpCheck is available
    try 
        if exist('gpopsLagrangeInterp','file')
            disp('gpopsLagrangeInterp is available')
        else
            disp('gpopsLagrangeInterp is NOT available')
            disp('this file is required to run gpopsUserInterp')
        end
    catch
        disp('gpopsLagrangeInterp is NOT available')
        disp('this file is required to run gpopsUserInterp')
    end
    disp(' ')
end
%--------------------------------------------------------------------------
function AddSubmissionContents(name) %#ok<DEFNU>
    disp('--- Adding submission contents to path')
    disp(' ')

    % current file
    fullfuncdir = which(name);

    % current folder 
    submissiondir = fullfile(fileparts(fullfuncdir));

    % add folders and subfolders to path
    addpath(genpath(submissiondir)) 
end
%--------------------------------------------------------------------------
function CloseThisFile(name) %#ok<DEFNU>
    disp(['--- Closing ', name])
    disp(' ')

    % get editor information
    h = matlab.desktop.editor.getAll;

    % go through all open files in the editor
    for k = 1:numel(h)
        % check if this is the file
        if ~isempty(strfind(h(k).Filename,name))
            % close this file
            h(k).close
        end
    end
end
%--------------------------------------------------------------------------
function OpenThisFile(name)
    disp(['--- Opening ', name])

    try
        % open the file
        open(name);
    catch % error
        disp(['Could not open ', name])
    end

    disp(' ')
end
%--------------------------------------------------------------------------
function RunSilent(str,silentflag)
    if silentflag
        O = evalc(str); %#ok<NASGU>
    else
        eval(str);
    end
end