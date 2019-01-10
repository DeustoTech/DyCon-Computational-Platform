clear;
%%              symU = [ u1 u2 ]
syms t
%% Discretizacion del espacio
N = 4;
%% Los vectores symY = [ y1 y2 y3 .. yn  ]

xi = 0; xf = 1;
xline = linspace(xi,xf,N);

symY = SymsVector('y',N);
symU = SymsVector('u',2);
%% Creamos Funcional

YT = 4*sin(pi*xline)';

symPsi  = (YT - symY).'*(YT - symY);
symL    = 0.001*(symU.'*symU);

Jfun = Functional(symPsi,symL,symY,symU);

%% Creamos el ODE 
%%%%%%%%%%%%%%%%

Y0 = 2*sin(pi*xline)';
%%%%%%%%%%%%%%%%

rho = 5;
A = rho*Laplacian(N);
%%%%%%%%%%%%%%%%  
B = zeros(N,2);
B(1,1) = 1;
B(N,2) = 1;
%%%%%%%%%%%%%%%%
Fsym  = A*symY + B*symU;
%%%%%%%%%%%%%%%%
T = 5;
odeEqn = ode(Fsym,symY,symU,'Y0',Y0,'T',T);


%% Veamos que queremos 

solve(odeEqn)

line(xline,YT,'Color','red')
line(xline,odeEqn.Y(end,:),'Color','blue')
legend('Target','Free Dynamics')

%% Creamos Problema de Control

iCP1 = ControlProblem(odeEqn,Jfun);

%% Solve Gradient
DescentParameters = {'MiddleStepControl',true,'InitialLengthStep',2.0};
Gradient_Parameters = {'maxiter',50,'DescentParameters',DescentParameters,'Graphs',true,'TypeGraphs','PDE'};
%
GradientMethod(iCP1,Gradient_Parameters{:})




% Several ways to run
% GradientMethod(iCP1)
% GradientMethod(iCP1,'DescentParameters',DescentParameters)
% GradientMethod(iCP1,'DescentParameters',DescentParameters,'graphs',true)

