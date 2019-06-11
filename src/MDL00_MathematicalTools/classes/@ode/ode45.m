function [tspan,StateVector] = ode45(iode,varargin)
%ODE45 Summary of this function goes here
%   Detailed explanation goes here

tspan = iode.tspan;
InitialCondition = iode.InitialCondition;
U = iode.Control.Numeric;

if isempty(varargin)
  iode.SolverParameters = {odeset('Mass',iode.MassMatrix)};
else
  iode.SolverParameters{:} = varargin{:};
  iode.SolverParameters{:}.Mass = iode.MassMatrix;
end


%Uinterp = arrayfun( @(ui) griddedInterpolant(tspan,U(:,ui)),1:iode.Udim,'UniformOutput',false);
%Ufun = @(t) arrayfun( @(ui) Uinterp{ui}(t),1:iode.Udim).';
%Ufun = @(t) interp1(tspan,U,t)';

Ufun = @(t) interp1(tspan,U,t,'nearest')';

dynamics = @(t,Y) iode.DynamicEquation.Numeric(t,Y,Ufun(t));

[tspan,StateVector] = ode45(dynamics,tspan,InitialCondition,iode.SolverParameters{:});

iode.StateVector.Numeric = StateVector;


end


function result = interp(tspan,U,t)
    [~ ,index] = min(abs(t-tspan));
    result = U(index,:);
end