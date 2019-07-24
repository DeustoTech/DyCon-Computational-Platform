clear;
%%
syms t
symY = SymsVector('y',4);
symU = SymsVector('u',4);
%%

%% Dynamics 
T = 20;
Y0 = [2,3.2,1,4].';
Fsym  = @(t,Y,U,Params) U;

dynamics = ode(Fsym,symY,symU,'InitialCondition',Y0,'FinalTime',T);
dynamics.Solver =  @eulere;
dynamics.Nt = 150;
%dynamics.SolverParameters = {odeset('RelTol',1e-1,'AbsTol',1e-1)};


%
beta=1;
alphaone=0.0392; %in the pdf "draft_Marposs3.pdf", this parameter is "\alpha_1".
alphatwo=24.5172; %in the pdf "draft_Marposs3.pdf", this parameter is "\alpha_2".

symPsi  = @(T,Y) 0;
symL    = @(t,Y,U) (U(1)^2+U(2)^2+U(3)^2+U(4)^2)+ ...
          (0.5)*(beta*alphaone)*((-(sin(Y(1))+sin(Y(2))+sin(Y(3))+sin(Y(4))))^2  + ...
                                   (cos(Y(1))+cos(Y(2))+cos(Y(3))+cos(Y(4)) )^2) + ...
          (0.5)*(beta*alphatwo)*(  (sin(Y(4))+sin(Y(3))-sin(Y(2))-sin(Y(1)) )^2   + ...
                                   (cos(Y(1))+cos(Y(2))-cos(Y(3))-cos(Y(4)) )^2);
%% 
% For last, you an create the functional object
%% 
% Creta the control Problem
iCP1 = Pontryagin(dynamics,symPsi,symL);
%%


% AMPL Neos Server
AMPLFile(iCP1,'AMPL.txt')
outfile = SendNeosServer('AMPL.txt');
%% Read Data
AMPLSolution  = NeosLoadData(outfile);
%% Solve Gradient
% %%
% U = zeros(dynamics.Nt,dynamics.ControlDimension);
% Y = zeros(dynamics.Nt,dynamics.StateDimension);
% 
% GetSymCrossDerivatives(iCP1)
% 
% GetSymCrossDerivatives(iCP1.Dynamics)
%   
% YU0 = [Y U];
% Udim = dynamics.ControlDimension;
% Ydim = dynamics.StateDimension;
% 
% options = optimoptions('fmincon','display','iter',    ...
%                        'MaxFunctionEvaluations',1e6,  ...
%                        'SpecifyObjectiveGradient',true, ...
%                        'CheckGradients',false,          ...
%                        'SpecifyConstraintGradient',true, ...
%                        'HessianFcn',@(YU,Lambda) Hessian(iCP1,YU,Lambda));
% %
% funobj = @(YU) StateControl2DiscrFunctional(iCP1,YU(:,1:Ydim),YU(:,Ydim+1:end));
% 
% clear ConstraintDynamics
% YU = fmincon(funobj,YU0, ...
%            [],[], ...
%            [],[], ...
%            [],[], ...
%            @(YU) ConstraintDynamics(iCP1,YU(:,1:Ydim),YU(:,Ydim+1:end)),    ...
%            options);
% 
% iCP1.Dynamics.StateVector.Numeric = YU(:,1:Ydim);
% iCP1.Dynamics.Control.Numeric = YU(:,Ydim+1:end);
%%
 DiscreteProblemFmincon(iCP1)
%%
figure
subplot(2,2,1)
plot(iCP1.Dynamics.Control.Numeric(1:end-1,:),'.-')
title('DyCon Toolbox Control');
subplot(2,2,3)
plot(iCP1.Dynamics.StateVector.Numeric(1:end-1,:),'.-')
title('DyCon Toolbox State');
%
subplot(2,2,2)
plot(AMPLSolution.Control','.-')
title('AMPL Control');
subplot(2,2,4)
plot(AMPLSolution.State','.-')
title('AMPL State');

figure
subplot(1,2,1)
plot(iCP1.Dynamics.Control.Numeric(1:end-1,:) - AMPLSolution.Control(:,1:end-1)','.-')
title('Diff Control');

subplot(1,2,2)
plot(iCP1.Dynamics.StateVector.Numeric(1:end-1,:) - AMPLSolution.State(:,1:end-1)','.-')
title('Diff State');