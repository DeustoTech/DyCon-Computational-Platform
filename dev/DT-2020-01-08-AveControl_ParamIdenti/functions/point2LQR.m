function afeedback = point2LQR(cartpole_dynamics,params,s0,u0)
%LQR_FEEDBACKCONTROL Summary of this function goes here
%   Detailed explanation goes here
%% LQR
syms x_ms v_ms theta_ms omega_ms theta2_ms omega2_ms u_ms
state = [x_ms theta_ms theta2_ms v_ms omega_ms omega2_ms].';

fsym = cartpole_dynamics(0,state,u_ms,params);

jac_fsym_x = jacobian(fsym,state);
jac_fsym_u = jacobian(fsym,u_ms);
%
A = subs(jac_fsym_x,state,s0);
A = double(subs(A,u_ms,0));

B = subs(jac_fsym_u,state,[0 0 0 0 0 0]');
B = double(subs(B,u_ms,u0));
%%
[K,~,~] = lqr(A,B,diag([1 1 1 1 1 1]),1e-1);
afeedback = @(t,s) -K*s; 

end

