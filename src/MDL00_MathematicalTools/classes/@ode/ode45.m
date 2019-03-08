function [tspan,StateVector] = ode45(iode,varargin)
%ODE45 Summary of this function goes here
%   Detailed explanation goes here

tspan = iode.tspan;
InitialCondition = iode.InitialCondition;
U = iode.Control.Numeric;


iode.SolverParameters = {odeset('Mass',iode.MassMatrix)};

Ufun = @(t) interp1(tspan,U,t)';
dynamics = @(t,Y) iode.Dynamic.Numeric(t,Y,Ufun(t));

[tspan,StateVector] = ode45(dynamics,tspan,InitialCondition,iode.SolverParameters{:});

iode.StateVector.Numeric = StateVector;

end

