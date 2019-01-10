function results = ClassicalGradient(A,theta0,tspan,u0,varargin)
%CLASSICALGRADIENT Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    
    addRequired(p,'A')
    addRequired(p,'tspan')
    addRequired(p,'u0')
    
    addOptional(p,'maxiter',100)
    addOptional(p,'beta',0.01)
    addOptional(p,'tol',0.001)

    
    parse(p,A,tspan,u0,varargin{:})
    
    maxiter = p.Results.maxiter;
    beta    = p.Results.beta;
    tol     = p.Results.tol;
    
    N       = length(A(:,1));
    %% Init
    Jhistory = zeros(maxiter,N);
    Thetahistory = zeros(N,length(tspan),maxiter);
    uhistory = zeros(length(tspan),N,maxiter);
    %%
    Jb = Inf;
    tic;
    u = u0;
    for iter = 1:maxiter
        % Primal problem
        fun_primal     = @(t,theta) A*theta + arrayfun(@(ncol) interp1(tspan,u(:,ncol),t),1:N)';
        [tspan, theta] = ode45(fun_primal,tspan,theta0);

        % Adjoint problem
        % p'(t,p) = A*p
        %%
        fun_adjoint = @(t,p)  A'*p;
        % Choose Initial Condition
        thetaT = theta(end,:)';

        p = zeros(length(tspan),N,N);
        for j = 1:N
            %
            p0 =   repmat(thetaT(j)',N,1) - thetaT;
            % Solve the adjoint problem 
            [tspan, p(:,:,j)] = ode45(fun_adjoint,tspan,p0);

            p(:,:,j) = flipud(p(:,:,j));
        end

        % Update Control
        nk = 1/sqrt(iter);
        sump = p(:,:,1);
        for k = 2:N 
            sump = sump +p(:,:,k);
        end
        sump = sump/N;

        u = u - nk*(beta*u-sump);
        %%
        % Stop Condition
        J = Jfunctional(u,tspan,thetaT,beta);
        if sum((Jb-J).^2) <= tol
            break
        else
            Jb = J;
            Jhistory(iter,:) =  J';
            Thetahistory(:,:,iter) = theta';
            uhistory(:,:,iter) = u;
        end
        %%
    end
    %% damos formato a la salida
    results.t = toc;
    results.Jhistory     = Jhistory(1:iter-1);
    results.Thetahistory = Thetahistory(:,:,1:iter-1);
    results.uhistory     = uhistory(:,:,1:iter-1);
    results.iters        = iter-1;
    results.N            = N;
    results.tspan        = tspan;

end

