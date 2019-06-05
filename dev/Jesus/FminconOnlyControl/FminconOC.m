
    %% Dynamics 
    clear
    %%
    Nx = 50;
    %%
    xline = linspace(-1,1,Nx);
    %%
    A = -FEFractionalLaplacian(0.8,1,Nx);
    %A = FDLaplacian(xline);
    B =  BInterior(xline,-0.3,0.8,'min',true,'mass',false);
    % problem parameters
    %
    dynamics            = pde('A',A,'B',B);
    dynamics.mesh       = xline;
    dynamics.FinalTime  = 0.5;
    dynamics.Nt         = 50; 
    %dynamics.MassMatrix = massmatrix(xline);
    %
    dynamics.InitialCondition = 0.5*cos(0.5*pi*xline');
    %% Target
    TargetDynamics = copy(dynamics);
    TargetDynamics.InitialCondition = 6*cos(0.5*pi*xline');
    U0 = zeros(dynamics.Nt,dynamics.Udim) + 1;

    [~ , ytarget ] = solve(TargetDynamics,'Control',U0);
    ytarget =  ytarget(end,:)';
    
    %% Initial Guess.
    uguess = 0.0+U0*0; %uguess(1:floor(dynamics.Nt/5),:) = 100;
    %% First 
    Y = dynamics.StateVector.Symbolic;
    U = dynamics.Control.Symbolic;
    L   = (Y-ytarget).'*(Y-ytarget);
    Psi = sym(0);
    iP = Pontryagin(dynamics,Psi,L);
    iP.Constraints.MinControl = 0;
    
    %%
    uguess = GradientMethod(iP,uguess,'display','all');
    uguess(uguess<0) = 0;
    %uguess = uguess*p.B;
    
    %% create structure
    p.dynamics = dynamics;
    p.ytarget  = ytarget;
    
    %% M 
    M  = dynamics.MassMatrix;
    MA = A;
    MB = B;
    
    funM = @(M) reshape(MA*reshape(M,Nx,Nx),Nx*Nx,1);
    M0 = eye(Nx,Nx);
    M0 = M0(:);
    %%
    options = odeset('MaxStep',0.01*dynamics.dt);
    [~ ,Msol] = ode23(@(t,M) funM(M),dynamics.tspan,M0,options);
    p.M = Msol;
    %%
    
    MT = (reshape(Msol(end,:),Nx,Nx));
    Msolfun = @(index) MT*((reshape(Msol(index,:),Nx,Nx))\MB);
    %Msolfun = @(index) ((reshape(Msol(index,:),Nx,Nx))\B);
    AllSol = zeros(dynamics.Nt,dynamics.Udim,Nx);
    for it = 1:dynamics.Nt
        AllSol(it,:,:) =  Msolfun(it)';
    end
    
    rowAllSol = [];
    for iNx = 1:Nx
       AA = AllSol(:,:,iNx);
       AA = AA(:)';
       rowAllSol = [rowAllSol;AA]; 
    end
    
    dx = xline(2) - xline(1);
    %rowAllSol = rowAllSol;
    %AllMsol = [AllMsol{:}];
    
    %AllMsol = reshape(AllMsol,dynamics.Udim*dynamics.Nt,Nx);
    %%
%     other = [];
%     for i = 1:5:20
%         other = [other;AllMsol(:,i:(i+5-1))];
%     end
%     AllMsol = other;
    %%

    p.M = p.dynamics.dt*rowAllSol;
    %% Options fmincon
    options = optimoptions(@fmincon,'display','iter', ...
                                    'Algorithm','interior-point', ...
                                    'MaxFunctionEvaluations',1e6, ...
                                    'CheckGradients',false, ...
                                    'SpecifyObjectiveGradient',true,        ...
                                    'SpecifyConstraintGradient',true,        ...
                                    'UseParallel',true, ...
                                    'PlotFcn',{@(x,optimvalues,init) fmpoc11(p,x,optimvalues,init), ...
                                               @(x,optimvalues,init) fmpoc12(p,x,optimvalues,init), ...
                                               @(x,optimvalues,init) fmpoc21(p,x,optimvalues,init)}); % options

    
    %% fmincon run
    uguess = uguess(:) + 1;
    %uguess(end+1) = 0.5;
    [x ,J] = fmincon(@(u) OBJFminconOC(u,p) ,uguess,             ...
                                         [],[],                  ...   % lineal ieq
                                         [],[],                  ...   % lineal eq
                                         [-1e-8 + zeros(1,dynamics.Udim*dynamics.Nt)],     ...   % low boundaries
                                         [],                     ...   % up boundaries
                                         @(u) CONFminconOC(u,p), ...   % nolineal constraints
                                         options);

         % obtain the optimal solution
      %%
    uyopt = x(1:dynamics.Udim*p.Nt); % extract
    uopt = reshape(yopt,p.Nt,p.Nu);
        
    uopt = x(1+p.Nx*p.Nt:end); % extract
    uopt = reshape(uopt,p.Nu,p.Nt);
    
    p.solution.yopt = yopt;
    p.solution.uopt = uopt;
    
    p.solution.Jopt = J;
    %%
    % objective function
  %%%

    function M = massmatrix(mesh)
        N = length(mesh);
        dx = mesh(2)-mesh(1);
        M = 2/3*eye(N);
        for i=2:N-1
            M(i,i+1)=1/6;
            M(i,i-1)=1/6;
        end
        M(1,2)=1/6;
        M(N,N-1)=1/6;

        M=dx*sparse(M);
    end
    

