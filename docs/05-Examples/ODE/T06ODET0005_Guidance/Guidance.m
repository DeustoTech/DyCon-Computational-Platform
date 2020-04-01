%% Two drivers, Flexible time
clear 
import casadi.*

N_sqrt =4;
M =1; N = N_sqrt^2;

t = SX.sym('t');
Y = SX.sym('y',[4*(M+N) 1]);
U = SX.sym('u',[M 1]);

ue = reshape(Y(1         : 2*N    ), [2 N]);
ve = reshape(Y(2*N+1     : 4*N    ), [2 N]);
ud = reshape(Y(4*N+1     : 4*N+2*M), [2 M]);
vd = reshape(Y(4*N+2*M+1 : 4*M+4*N), [2 M]);

kappa = U(1:M);

perp = @(u) [-u(2,:);u(1,:)];
square = @(u) u(1,:).^2+u(2,:).^2;

f_e2 = @(x) repmat(2./x, [2 1]);
f_d2 = @(x) repmat(-(-5.5./x+10./x.^2-2),[2 1]);
rm = 1.5; eps = 2.5;
f_ee = @(x) repmat(eps*((12*rm^6)./(x+1).^7 - (12*rm^12)./(x+1).^13), [2 1]);

nu_e = 2.0; nu_d = 2.0;

dot_ue = ve; dot_ud = vd;
uebar = mean(ue,2);

dot_vd = -f_d2(square(ud-uebar)).*(ud-uebar) - nu_d*vd + 0.1*repmat(kappa.',[2 1]).*perp(ud-uebar);

dot_ve = - nu_e*ve;
for j=1:M
  dot_ve = dot_ve - 2*f_e2(square(ud(:,j)-ue)).*(ud(:,j)-ue);
end
for j=1:N
  dot_ve = dot_ve + 2*f_ee(square(ue(:,j)-ue)).*(ue(:,j)-ue);
end

%% Create Dynamics
tf = 15;Nt = 150;
tspan = linspace(0,tf,Nt);
F = casadi.Function('Fs',{t,Y,U},{ [dot_ue(:);dot_ve(:);dot_ud(:);dot_vd(:)]});
dynamics = ode(F,Y,U,tspan);
SetIntegrator(dynamics,'RK4')


%% Initial Condition 

ve_zero = zeros(2, N);vd_zero = zeros(2, M);
ue_zero = zeros(2, N);ud_zero = zeros(2, M);

x_zero = repmat(linspace(-1,1,N_sqrt),[N_sqrt 1]);
y_zero = x_zero';

ue_zero(1,:) = x_zero(:);
ue_zero(2,:) = y_zero(:);

for j=1:M
  ud_zero(:,j) = 8*[cos(2*pi/M*j);sin(2*pi/M*j)];
end

Y0 = [ue_zero(:);ve_zero(:);ud_zero(:);vd_zero(:)];
%
dynamics.InitialCondition = Y0;

%%
u_f = [5;5];

Yt = solve(dynamics,ZerosControl(dynamics));
plotGuidance(full(Yt)',dynamics.tspan,N,M,u_f)

%%
%% Define Optimal control problem
%
L   = casadi.Function('L'  ,{t,Y,U},{ 1e-2*(kappa.'*kappa) });
Psi = casadi.Function('Psi',{Y}    ,{ (1/N)*sum(sum((ue - u_f).^2))  });
%
iP = ocp(dynamics,L,Psi);
% Contratins
iP.constraints.MinControlValue = -5;
iP.constraints.MaxControlValue = +5;
%% Solve Optimal Control Problem
ControlGuess = ZerosControl(dynamics);

[OptControl_1 ,OptThetaVector_1] =  ArmijoGradient(iP,ControlGuess,'MinLengthStep',1e-15,'MaxIter',100);

%[OptControl_1 ,OptThetaVector_1] =  ClassicalGradient(iP,ControlGuess,'LengthStep',1e-1,'MaxIter',100);
% take the solution
YO_tline = full(OptThetaVector_1)';
%% Animation 
figure(2)
clf

aniGuidance(YO_tline,N,M,u_f)

%% Plot
plotGuidance(YO_tline,dynamics.tspan,N,M,u_f)


