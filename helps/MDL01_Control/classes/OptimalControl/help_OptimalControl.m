%% 
% First define the vectors
%%
% $$ symY = \left( \begin{matrix}   y1 \\
%                                   y2 
%                  \end{matrix} \right)
%    symU = \left( \begin{matrix}   u1 \\
%                                   u2 
%                   \end{matrix} \right) $$
%%
clear;
syms t
symY = sym('y',[2 1]);
symU = sym('u',[1 1]);
%%
% *Ordinary differential equation*
%%
% In this case we will define the following differential equation
%%
% $$ \left( \begin{matrix}   \dot{S} \\
%                            \dot{I} 
%                  \end{matrix} \right)
%    = 
%       \left( \begin{matrix}   \lambda - \beta S I - \sigma_1 S \\
%                               \beta S I - u_1 I - \sigma_2 I
%                   \end{matrix} \right) $$
Lambda = 1;beta = 0.5;
sigma1 = 0.1;sigma2 = 0.1;

S = symY(1);I = symY(2);
Fsym(1)  = Lambda - beta*S*I -  sigma1*S; 
Fsym(2)  = beta*S*I - symU(1)*I - sigma2*I ;
%%
FinalTime = 5;
S0 = 100 ;I0 = 15;
Y0 = [ S0 ; I0];
Dynamics = ode(Fsym.',symY,symU,'Condition',Y0,'FinalTime',FinalTime);
%%
% *Cost Functional*
%%
% $$ J = \Psi(Y(T),t) + \int_0^T L(Y(t,U),U(t),t) dt$$
%%
% In this case,
%%
% $$ J = A \int_0^T (\vert U \vert^2 + I) dt$$
%% 
% Now, We can create the control problem
A = 1;
symPsi  = sym(0);
symL    = A*(symU.'*symU) + I;
%
iCP1 = OptimalControl(Dynamics,symPsi,symL);
%%
% and solve by Classical Gradient Method
GradientMethod(iCP1)
%%
plot(iCP1)

