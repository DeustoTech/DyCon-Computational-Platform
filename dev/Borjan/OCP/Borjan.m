%%
%% Semi-linear semi-discrete heat equation and collective behavior
%%
% Definition of the time 
clear 
syms t
% Discretization of the space

N = 70;
xi = -2; xf = 2;
xline = linspace(xi,xf,N+2);
xline = xline(2:end-1);

%%
Y = SymsVector('y',N);
U = SymsVector('u',N);
%% Dynamics 
alpha = 1e-3;
epsilon = 1e-2;
A = FDLaplacian(xline);
% 
F  = @(Y) NonLinearTerm(Y,alpha);
dF = @(Y) DiffNonLinearTerm(Y,alpha);
%
dx = xline(2) - xline(1);
%
Y_t = @(t,Y,U,Params) A*Y + 1/epsilon*F(-Y) + U + (1/dx^2)*[0.8;zeros(N-2,1);0.8];
%
Dyn = pde(Y_t,Y,U);
% Setting PDE
Dyn.mesh   = xline;
Dyn.Solver = @ode23;
Dyn.Nt     = 150;
Dyn.FinalTime        = 0.3;
Dyn.InitialCondition = InitialConditionFcn(xline);
%
% Jacobian F_u
Dyn.Derivatives.Control.Num = @(t,Y,U,Params) eye(N);
% Jacobian F_y
Dyn.Derivatives.State.Num   = @(t,Y,U,Params) A + 1/epsilon*dF(-Y);

%% Free Solution
[tspan,Ysolution] = solve(Dyn);
%
figure
surf(Ysolution)
%
%% Create Optimal Control Problem
%
% min J
%
% J = Psi(Y,T) + \int_0^T L(t,Y,U)dx
%
YT = 0.8 + 0*xline';
beta = dx^4;
%
Psi  = @(T,Y) dx*(YT - Y).'*(YT - Y);
L    = @(t,Y,U)  dx*(YT - Y).'*(YT - Y) + beta*dx*0.5*alpha*(U.'*U);
% 
OCP = Pontryagin(Dyn,Psi,L);
%%
U0 = -ones(Dyn.Nt,Dyn.ControlDimension);
U0 = GradientMethod(OCP,U0,'Graphs',true,'EachIter',2,'DescentAlgorithm',@AdaptativeDescent)
