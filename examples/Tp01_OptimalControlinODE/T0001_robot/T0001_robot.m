clear
syms x1 x2 theta nu1 nu2 omega

syms u1 u2 


alpha = 0.2;


dynamics = [ nu1;   ...
             nu2;   ...
             omega; ...
             (u1 + u2)*cos(theta); ...
             (u1 + u2)*sin(theta); ...
             alpha*(u1-u2)];
         
         
 
 
 Y = [x1; x2; theta; nu1; nu2; omega];
 U = [u1; u2];
iode = ode(dynamics,Y,U);
iode.InitialCondition = [-10;-10;0.5*pi;0;0;0];
iode.FinalTime = 12;
iode.Solver = @ode23tb;
iode.dt = 0.5;

YT = [0;0;0;0;0;0];

delta = 1;
gamma = 1;
Psi = 0.5*delta*(Y-YT).'*(Y-YT);
L   = gamma*(abs(u1) + abs(u2));
%L   = gamma*((u1)^2 + u2^2);

iCP = OptimalControl(iode,Psi,L);

U0 = iode.Control.Numeric;
options = optimoptions(@fminunc,'display','iter','SpecifyObjectiveGradient',true);
fminunc(@(U)Control2Functional(iCP,U),U0,options)

%iCP.constraints.Umax = 0.2;
%iCP.constraints.Umin = -0.2;

GradientMethod(iCP,'Graphs',true,'DescentAlgorithm',@ConjugateGradientDescent,'display','all')