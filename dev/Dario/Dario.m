%%
% In this tutorial we will apply the DyCon toolbox to solve
%%
% $$
% \min_{(u_1,u_2)\in L^2(0,T)^2}J_{T}(u) = \frac12 \int_0^T\left( | u_1(t) |^2+| u_2(t) |^2 \right)dt+\frac{\beta}{2}\int_0^T\int_{0}^{1} |y(t,x)-z(x)|^2 dxdt+\int_0^1q_0(x)y(T,x)dx,
% $$
%%
% where:
%%
% $$
% \begin{cases}
% y_t- y_{xx}+y^3 = 0\hspace{2.8 cm} \mbox{in} \hspace{0.10 cm}(0,T)\times (0,1)\\
%
% y(t,0) = u_1(t)  andand \mbox{on}\hspace{0.10 cm} (0,T)\\
% y(t,1) = u_2(t)  andand \mbox{on}\hspace{0.10 cm} (0,T)\\
%
% y(0,x) = y_0(x)  andand \mbox{in}\hspace{0.10 cm}  (0,1).
% \end{cases}
% $$
%% 
% The functional $J_T$ is made of two addenda. The first one penalizes the
% control, while the second one is a tracking term penalizing
% the distance between the state and the target.
% Our goal is to keep the state near the target for all times,
% by a cheap control.
% As $\beta$ increases, the distance between
% the optimal state and the target decreases.

%%
% For time horizon $T$ large, one can check the emergence of the Turnpike property (see [1]). For further details about the problem, see e.g. [1], [2] or [3].

%% STEP 1. Import CasADi.
clear all
import casadi.*

%% STEP 2. Define the parameters for the algorithm.

% Definition of the symbolic variable standing for the time
ts = SX.sym('t');
% Discretization of the space
Nx = 50;
%Nx = 10;
xline = linspace(0,1,Nx);
% Definition of A, the "model", and B the control operator
[A,B] = GetABmatrixnew(Nx);

%% STEP 3. Define the optimal control problem.

Ysred = SX.sym('y',[Nx-2 1]); %state restricted at nodes x_i = i/(Nx-1), for i=2,\dots,Nx-1. We do not consider the state at the boundary, since it is given by the boundary condition (the control).
Us    = SX.sym('u',[1 1]);

%%
% We define the functional that we want to minimize

% Time horizon
T = 2.0;
Nt = 500;
tspan = linspace(0,T,Nt);

theta = @(x,k) 0.5 + 0.5*tanh(k*x);

t_mid = floor(Nt/2);
t_mid = tspan(t_mid);

k = 4;
tspan = T*theta(tspan-t_mid,k);

if length(unique(tspan)) ~= Nt
    error('k value is so large')
end
%%
% Penalization parameter for the state.
beta = 1;
%%
% Initial datum for the state equation.
Y0 = 10*ones(1,Nx);
Y0red = Y0(2:Nx-1);
%%
% final cost
Q0 = zeros(Nx-2,1); %projection_coarse_grid(qwpos',Nx); %row vector
%%
% Target for the state. 
%%
Z = 410000*ones(Nx-2,1);
indexs = logical((xline(2:end-1) < 0.75).*(xline(2:end-1) > 0.25));
Z(indexs) = -10300000;
%% 
%%

%%
% We create the ODE object
% Our ODE object will be the semi-discretization of the semilinear heat equation.
% We define the non linearity and the interaction of the control with the dynamics.

%%
% Definition of the non-linearity
% $$ -(\cdot)^3 $$
%%
G = casadi.Function('NLT',{ts,Ysred},{-Ysred.^3});

%%
% Putting all the things together
F = casadi.Function('F',{ts,Ysred,Us},{A*Ysred + G(ts,Ysred) + B*Us});
% Creation of the ODE object

%%
% We create the ODE-object and we change the resolution to $deltat=0.01$ in order
% to see the variation in a small time scale. We will get the values of the
% solution in steps of size odeEqn.dt, if we do not care about
% modifying this parameter in the object, we might get the solution in
% certain time steps that will hide part of the dynamics.

%%
%%
ipde = semilinearpde1d(Ysred,Us,A,B,G,tspan,xline);
%%
%Fs = casadi.Function('Fs',{ts,Ysred,Us},{A*Ysred+B*Us+G(Ysred)});
%ipde = pde1d(Fs,Ysred,Us,tspan,xline);
SetIntegrator(ipde,'OperatorSplitting')
%
ipde.InitialCondition = Y0red';
ipde.InitialCondition = Z';

%%
% We solve the equation and we plot the free solution applying solve to odeEqn and we plot the free solution.
%%
U0 = 0*ones(1,Nt);
%U0 = ZerosControl(ipde);
Yfreered = solve(ipde,U0);
Yfreered = full(Yfreered);
%
figure(1);
surf(xline(2:end-1),tspan,Yfreered','MeshStyle','col','LineWidth',1.5);
title('Free Dynamics')
xlabel('space discretization')
ylabel('Time')
yticks([1 Nt])
yticklabels([tspan(1) tspan(end)])

%%
% We create the object that collects the formulation of an optimal control problem  by means of the object that describes the dynamics odeEqn, the functional to be minimized Jfun and the time horizon T
%%
L   = Function('L'  ,{ts,Ysred,Us},{ 0.5*( Us.'*Us + beta*((Ysred-Z).'*(Ysred-Z))*(1/(Nx-1)) )}); %we miss the difference state-target at the boundary of [0,1]. This is small if Nx is large.
Psi = Function('Psi',{Ysred}      ,{ (Q0.'*Ysred)*(1/(Nx-1)) }); %we miss the final cost at the boundary of [0,1]. This is small if Nx is large.

iocp = ocp(ipde,L,Psi);
iocp.TargetState = Z;
%% STEP 4. Define the optimal control problem. We apply IPOpt to obtain an approximation of a local minimum (our functional might not be convex).
%U0 =ZerosControl(ipde);
U0 = -10*ones(1,Nt);
% intergrator:
% - SemiLinearBackwardEuler 
% - BackwardEuler
% - CrankNicolson (default)
% - rk4
% - rk5
% - rk8

StateGuess = repmat(Z,1,Nt);
[OptControl ,OptState]  = IpoptSolver(iocp,U0,'integrator','CrankNicolson','StateGuess',StateGuess);
%[OptControl ,OptState]  = ArmijoGradient(iocp,U0,'MinLengthStep',1e-60);
%[OptControl ,OptState]  = ClassicalGradient(iocp,U0,'LengthStep',1e-10);

%% STEP 5. Plot the obtained optimal control and state, together with the free dynamics.
surf(tspan,xline(2:end-1),OptState);shading interp
%% References
% [1]: Porretta, Alessio and Zuazua, Enrique, Remarks on long time versus steady state optimal control, Mathematical Paradigms of Climate Science, Springer, 2016, pp. 67--89.
%
% [2]: Casas, Eduardo and Mateos, Mariano, Optimal control of partial differential equations,
%    Computational mathematics, numerical analysis and applications,
%    Springer, Cham, 2017, pp. 3--5.
%
% [3]: Tr{\"o}ltzsch, Fredi, Optimal control of partial differential equations, Graduate studies in mathematics, American Mathematical Society, 2010.