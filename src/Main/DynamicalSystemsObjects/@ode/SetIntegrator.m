function SetIntegrator(idyn,method)
%CREATECASADIINTEGRATOR Summary of this function goes here
%   Detailed explanation goes here

    %% Get Vars
    F  = idyn.DynamicFcn;
    Nt = idyn.Nt;
    Nx = idyn.StateDimension;
    Nu = idyn.ControlDimension;
    tspan = idyn.tspan;
    % Create Symbolical 
    State0  = idyn.State.sym; 
    Statetime   = casadi.SX.sym('Xt',Nx,Nt);
    Controltime = casadi.SX.sym('Ut',Nu,Nt);
    %%
    M = idyn.MassMatrix;


    %% Set Integrator
    switch method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'casadi' 
            Xs = idyn.State.sym;
            Us = idyn.Control.sym;
            ts = idyn.ts;
            dae = struct('x',Xs,'p',Us,'ode',idyn.DynamicFcn(ts,Xs,Us));
            
           opts = struct('tf',tspan(end)/Nt);

            F = casadi.integrator('F', 'idas', dae,opts);
            
            Integrator = @(State0,ControlTime)  InitAndControl2Sol(F,State0,ControlTime);
 
        case 'BackwardEuler'
        %%
            Statetime(:,1) = State0;
            for it = 2:Nt
                 dt = tspan(it) - tspan(it-1);
                 Statetime(:,it) = Statetime(:,it-1) + dt*(M\F(tspan(it-1),Statetime(:,it-1),Controltime(:,it-1)));
            end
            Integrator = casadi.Function('Ft',{State0,Controltime},{Statetime});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'RK4'
        %%    
            Statetime(:,1) = State0;

            for it = 2:Nt
                dt = tspan(it) - tspan(it-1);
                k1 = F(tspan(it-1),Statetime(:,it-1),Controltime(:,it-1)  );
                k2 = F(tspan(it-1) + 0.5*dt, Statetime(:,it-1)+ 0.5*k1*dt  , 0.5*Controltime(:,it-1) + 0.5*Controltime(:,it));
                k3 = F(tspan(it-1) + 0.5*dt, Statetime(:,it-1)+ 0.5*k2*dt  , 0.5*Controltime(:,it-1) + 0.5*Controltime(:,it));
                k4 = F(tspan(it-1) + 1.0*dt, Statetime(:,it-1)+ 1.0*k3*dt  , 1.0*Controltime(:,it));
                Statetime(:,it) = Statetime(:,it-1) + (1/6)*dt*(k1+k2+k3+k4);
            end
            %
            Integrator = casadi.Function('Ft',{State0,Controltime},{Statetime});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'LinearFordwardEuler'
        %%
            dt = tspan(2) - tspan(1);
            N = idyn.StateDimension;
            %
            idyn.C = speye(N,N)-dt*(M\idyn.A);
            idyn.C = inv(idyn.C);

            idyn.D = idyn.C*(dt*(M\idyn.B));
    
            Statetime(:,1) = State0;
            for it = 2:Nt
                 Statetime(:,it) = idyn.C*Statetime(:,it-1) +  idyn.D*Controltime(:,it);
            end
            Integrator = casadi.Function('Ft',{State0,Controltime},{Statetime});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'SemiLinearFordwardEuler'
            NLT = idyn.NonLinearTerm;%
            Ys  = idyn.State.sym;
            g = casadi.Function('g',{Ys},{NLT(Ys(1))./Ys(1)});
            A = idyn.A;
            B = idyn.B;
            %
            Statetime(:,1) = State0;
            for it = 2:Nt
                dt = idyn.tspan(it) - idyn.tspan(it-1);
                C  = diag(1-dt*g(Statetime(:,it-1))) - dt*A;
                yu = Statetime(:,it-1)  + B*Controltime(:,it-1);
                Statetime(:,it) = C\yu;
            end
            Integrator = casadi.Function('Ft',{State0,Controltime},{Statetime});            
    end
    %%
    %%
    idyn.method = method;
    idyn.solver = Integrator;
    
    function sol = InitAndControl2Sol(F,InitialCondition,Control)
        
        sol = casadi.DM(Nx,Nt);
        
        sol(:,1) = InitialCondition;
        for its = 2:Nt
            solution =  F('x0',sol(:,its-1),'p',Control(:,its-1));
            sol(:,its) = solution.xf;
        end
    end
end



