%--------------------------------------------------------------------------
% gpopsUserInterp.m
% Interpolate a GPOPS solution to a user-defined mesh
%--------------------------------------------------------------------------
% inputs
%  - output   : gpops output structure
%  - usermesh : user-defined mesh (see GUI_defineMesh and the examples)
%  - varargin : optional arguments 
%    - 'endpts' : include the phase endpoints
% outputs
%  - output   : modified gpops output structure
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber (danielrherber)
% Link: https://github.com/danielrherber/gpops-user-interp
%--------------------------------------------------------------------------
function output = gpopsUserInterp(output,usermesh,varargin)

% check if the following function is available
if ~exist('gpopsLagrangeInterp','file')
    error('-> this function requires gpopsLagrangeInterp.m')
end

% determine if you want to include the phase endpoints
endptsflag = any(strcmpi('endpts',varargin));

% extract solution and setup structure
solution = output.result.solution;
mesh = output.result.setup.mesh;
collocation = output.result.collocation;

% number of phases
nphs = length(solution.phase);

% obtain the user-defined mesh
usermesh = GUI_defineMesh(usermesh,solution,nphs);

% initialize
phase(nphs) = struct('time',[],'state',[],'control',[]);

% go through each phase
for phs = 1:nphs

    % get original grid, states, and controls
    torig = solution.phase(phs).time;
    Yorig = solution.phase(phs).state;
    Uorig = solution.phase(phs).control;

    % number of states
    ny = size(Yorig,2);

    % number of controls
    nu = size(Uorig,2);

    % current desired mesh
    T = usermesh{phs};    

    % boundary time values
    t0 = torig(1);
    tf = torig(end);

    % include phase endpoints?
    if endptsflag
        T = unique([t0;tf;T]);
    end

    % get final mesh information
    colpoints = mesh.phase(phs).colpoints;
    fraction = mesh.phase(phs).fraction;
    s = collocation(phs).s;

    % calculate interval endpoints
    cfraction = cumsum(fraction);
    Tends = [t0,(1-cfraction)*t0+tf*cfraction];

    % calculate interval indices
    cumcolpoints = [0,cumsum(colpoints)];

    % number of intervals
    nint = numel(colpoints);

    % initialize
    t = cell(nint,1); Y = cell(nint,1); U = cell(nint,1);

    % go through each interval
    for idx = 1:nint

        % original indices
        Iorig = cumcolpoints(idx)+1:cumcolpoints(idx+1)+1;

        % extract scaled grid
        sc = [s(Iorig(1:end-1),2);1];

        % interval endpoints
        tmin = Tends(idx);
        tmax = Tends(idx+1);

        % compute intermediate quantities
        tsub = tmax - tmin;
        tadd = tmax + tmin;

        % indices in interpolation grid in current interval
        % Ic = (T >= tmin) & (T <= tmax);
        Ic = (T-tmin) >= -100*eps & (T-tmax) <= 1000*eps; % slightly more robust implementation, still not perfect

        % check if there are any nodes in the interval
        if any(Ic)
            % scale current interpolation time grid
            tc = (2*T(Ic) - tadd)/tsub;

            % interpolate the states
            Yc = zeros(length(tc),ny);
            for k = 1:ny
                Yc(:,k) = gpopsLagrangeInterp(sc,Yorig(Iorig,k),tc);
            end

            % interpolate the controls
            Uc = zeros(length(tc),nu);
            for k = 1:nu
                Uc(:,k) = interp1(sc,Uorig(Iorig,k),tc,'pchip');
            end

            % save
            t{idx} = T(Ic);
            Y{idx} = Yc;
            U{idx} = Uc;

            % remove completed
            T(Ic) = [];
        end
    end

    % combine
    ts = vertcat(t{:});
    Ys = vertcat(Y{:});
    Us = vertcat(U{:});

    % save
    phase(phs).time = ts;
    phase(phs).state = Ys;
    phase(phs).control = Us;

end

% save
output.result.interpsolution.phase = phase;

end
% determine the user-defined mesh from the inputs
function T = GUI_defineMesh(usermesh,solution,nphs)

% numeric array for equidistant grids
if isnumeric(usermesh) % create equidistant grids

    % the entire time horizon has a specified number of nodes
    if length(usermesh) == 1
        t0 = solution.phase(1).time(1);
        tf = solution.phase(end).time(end);
        Ttotal = linspace(t0,tf,usermesh)';
        T = cell(nphs,1);

        % go through each phase
        for phs = 1:nphs
            tphs = solution.phase(phs).time;
            t0phs = tphs(1);
            tfphs = tphs(end);

            T{phs} = Ttotal(Ttotal>=t0phs & Ttotal<=tfphs);
        end

    % each phase has a specified number of nodes
    elseif length(usermesh) == nphs
        T = cell(nphs,1);

        % go through each phase
        for phs = 1:nphs
            tphs = solution.phase(phs).time;
            t0phs = tphs(1);
            tfphs = tphs(end);

            T{phs} = linspace(t0phs,tfphs,usermesh(phs))';
        end

    % error condition
    else
        error('-> improper usermesh: incorrect number of phases')

    end

% cell array for completely user-defined mesh
elseif iscell(usermesh)

    % same user mesh on all phases
    if length(usermesh) == 1
        % copy usermesh to all phases
        T = cell(nphs,1);
        T(:) = usermesh;

    % check if the usermesh has the correct number of phases
    elseif length(usermesh) == nphs
        % copy mesh
        T = usermesh;

    % error condition
    else
        error('-> improper usermesh: incorrect number of phases')

    end

% error condition
else
    error('-> improper usermesh: wrong data type')

end

end