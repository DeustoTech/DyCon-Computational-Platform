function solve(iode,varargin)
%SOLVE Summary of this function goes here
%   Detailed explanation goes here

    p = inputParser;
    
    addRequired(p,'iode')
    %
    u0_default = zeros(length(iode.tline),length(iode.symU));
    %
    addOptional(p,'U',u0_default)

    parse(p,iode,varargin{:})
    
    U = p.Results.U;
    %%
    
    U_fun   = @(t)   interp1(iode.tline,U,t);   
    % Creamos dY/dt (t,Y)  a partir de la funcion dY_dt_uDepen    
    dY_dt   = @(t,Y) double(iode.numF(t,Y,U_fun(t)));
    
    % Obtenemos Y = [y(t1) y(t2) ... ] 
    [~,iode.Y] = ode45(dY_dt,iode.tline,iode.Y0);
end

