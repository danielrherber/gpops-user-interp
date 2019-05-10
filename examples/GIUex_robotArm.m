%--------------------------------------------------------------------------
% GIUex_robotArm.m
% Test file for Robot Arm problem
% http://www.gpops2.com/Examples/RobotArm.html
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Primary Contributor: Daniel R. Herber (danielrherber)
% Link: https://github.com/danielrherber/gpops-user-interp
%--------------------------------------------------------------------------
clear; clc; close all

% load solution data structure
load('robotArm-1')

% store original 
old = output.result.interpsolution;

% time horizon
t0 = old.phase(1).time(1);
tf = old.phase(end).time(end);

% optional inputs
inputs = [];

%--------------------------------------------------------------------------
% test number (change this)
testnum = 1;

% test cases
switch testnum
%--- base cases
    case 1
        usermesh = 30; % total number of equidistant nodes
        inputs = 'endpts'; % include endpoints
    case 2
        usermesh = {old.phase.time}'; % original interpolation mesh
    case 3
        usermesh = {output.result.solution.phase.time}'; % original gpops mesh
    case 4
        usermesh{1} = linspace(t0,tf,30)'; % same as case 1
    case 5
        usermesh{1} = (tf-t0)*rand(50,1)+t0; % rand, unordered mesh
%--- trivial cases   
    case 10
        usermesh = 0; % single zero ok
    case 11 
        usermesh{1} = []; % single empty meshes ok
%--- error cases
    case 20 
        usermesh = [100,3,50]; % too many entries
    case 21
        usermesh = []; % too few entries
end

%--------------------------------------------------------------------------
% obtain new interpsolution
outputnew = gpopsUserInterp(output,usermesh);

%--------------------------------------------------------------------------
% data
T0 = vertcat(output.result.solution.phase.time);
Y0 = vertcat(output.result.solution.phase.state);
U0 = vertcat(output.result.solution.phase.control);

T1 = vertcat(old.phase.time);
Y1 = vertcat(old.phase.state);
U1 = vertcat(old.phase.control);

new = outputnew.result.interpsolution;
T2 = vertcat(new.phase.time);
Y2 = vertcat(new.phase.state);
U2 = vertcat(new.phase.control);

%--------------------------------------------------------------------------
% plots
hf = figure; hf.Color = [1 1 1];
subplot(1,3,1); hold on; xlabel('time'); ylabel('controls');
plot(T0,U0,'.-k','markersize',18);
title(['gpops mesh: ',num2str(length(T0)),' points'])
subplot(1,3,2); hold on; xlabel('time'); ylabel('controls');
plot(T1,U1,'.-r','markersize',12);
title(['orig interp: ',num2str(length(T1)),' points'])
subplot(1,3,3); hold on; xlabel('time'); ylabel('controls');
plot(T2,U2,'.-b','markersize',12);
title(['user interp: ',num2str(length(T2)),' points'])

hf = figure; hf.Color = [1 1 1];
subplot(1,3,1); hold on; xlabel('time'); ylabel('states');
plot(T0,Y0,'.-k','markersize',18);
title(['gpops mesh: ',num2str(length(T0)),' points'])
subplot(1,3,2); hold on; xlabel('time'); ylabel('states');
plot(T1,Y1,'.-r','markersize',12);
title(['orig interp: ',num2str(length(T1)),' points'])
subplot(1,3,3); hold on; xlabel('time'); ylabel('states');
plot(T2,Y2,'.-b','markersize',12);
title(['user interp: ',num2str(length(T2)),' points'])