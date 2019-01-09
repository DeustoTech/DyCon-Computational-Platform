function  AverageClassicalGradient(iCPD,xt,varargin)
% description: The Average Control solve an optimal control problem which is constructed to
%   control the distance between the average of the states in the last time
%   and a given final target. The states are defined via a
%   parameter-dependent linear system of differential equations
%   $$\\dot{x}(t,\\nu)=A(\\nu)x(t,\\nu)+B(\\nu)u(t)$$
%   The optimum is computed applying different iterative algorithms based
%   on gradient descent methods. This function solve a particular optimal control problem using
%   the classical gradient descent algorithm. The restriction of the optimization 
%   problem is a parameter-dependent finite dimensional linear system. Then, the 
%   resulting states depend on a certain parameter. Therefore, the functional is
%   constructed to control the average of the states with respect to this parameter.
% autor: AnaN
% MandatoryInputs:   
%   iCPD: 
%    description: Control Parameter Dependent Problem 
%    class: ControlParameterDependent
%    dimension: [1x1]
%   xt: 
%    description: The target vector where you want the system to go
%    class: double
%    dimension: [iCPD.Nx1]
% OptionalInputs:
%   tol:
%    description: tolerance of algorithm, this number is compare with $J(k)-J(k-1)$
%    class: double
%    dimension: [1x1]
%    default:   1e-5
%   beta:
%    description: This number is the power of the control, is define by follow expresion $$J = \\min_{u \\in L^2(0,T)} \\frac{1}{2} \\left[ \\frac{1}{|\\mathcal{K}|} \\sum_{\\nu \\in \\mathcal{K}} x \\left( T, \\nu \\right) - \\bar{x} \\right]^2  + \\frac{\\beta}{2} \\int_0^T u^2 \\mathrm{d}t, \\quad \\beta \\in \\mathbb{R}^+ $$ 
%    class: double
%    dimension: [1x1]
%    default:   1e-5
%   gamma:
%    description: Length Step of the gradient Method. The control is update as follow $$u_{k+1} = u_{k} + \\gamma \\nabla u_{k}$$
%    class: double
%    dimension: [1x1]
%    default:   1e-1
%   MaxIter:
%    description: Maximun of iterations of this method
%    class: double
%    dimension: [1x1]
%    default:   100
    p = inputParser;
    addRequired(p,'iCPD')
    addRequired(p,'xt',@xt_valid)
    addOptional(p,'tol',1e-5)
    addOptional(p,'beta',1e-1)
    addOptional(p,'gamma',0.5)
    addOptional(p,'MaxIter',100)
    
    parse(p,iCPD,xt,varargin{:})

    tol     = p.Results.tol;
    beta    = p.Results.beta;
    gamma   = p.Results.gamma;
    MaxIter = p.Results.MaxIter;

    K = iCPD.K;
    A = iCPD.A;
    B = iCPD.B;
    span = iCPD.span;
    
    %% init
    tic;
    primal_odes = zeros(1,iCPD.K,'LinearODE');
    for index = 1:K
        %
        primal_odes(index)      = LinearODE(A(:,:,index),'B',B(:,:,index));
        % all have the same control
        primal_odes(index).u    = iCPD.u0;
        % time intervals
        primal_odes(index).span = span;
        % initial state
        primal_odes(index).x0   = iCPD.x0;
    end

    %
    adjoint_odes = zeros(1,K,'LinearODE');
    for index = 1:K
        adjoint_odes(index)      = LinearODE(A(:,:,index)');
        % all have the same control
        adjoint_odes(index).u    = iCPD.u0;
        % time intervals
        adjoint_odes(index).span = span;
    end

  
    %%
    error_value = Inf;
    iter = 0;
    % array here we will save the evolution of average vector states
    xhistory = {};
    uhistory = {}; 
    error_history = zeros(1,MaxIter); 
    Jhistory =  zeros(1,MaxIter); 
    while (error_value > tol && iter < MaxIter)
        iter = iter + 1;
        % solve primal problem
        % ====================
        solve(primal_odes);
        % calculate mean state final vector of primal problems  
        xMend = forall({primal_odes.xend},'mean');

        % solve adjoints problems
        % =======================
        % update new initial state of all adjoint problems
        for iode = adjoint_odes
            iode.x0 = -(xMend' - xt);
        end
        % solve adjoints problems with the new initial state
        solve(adjoint_odes);

        % update control
        % ===============
        % calculate mean state vector of adjoints problems 
        pM = adjoint_odes(1).x*B(:,:,1);
        for index =2:K
            pM = pM + adjoint_odes(index).x*B(:,:,index);
        end
        pM = pM/K;
        % reverse adjoint variable
        pM = flipud(pM);    
        % Control update
        u = primal_odes(1).u; % catch control currently
        Du = beta*u - pM;
        u = u - gamma*Du;
        % update control in primal problems 
        for index = 1:K
            primal_odes(index).u = u;
        end
        % Control error
        % =============
        Au2   =  trapz(span,u.^2);
        %
        Jcurrent =  0.5*(xMend' - xt)'*(xMend' - xt) + 0.5*beta*Au2;
        
        if iter ~= 1
            error_value =  abs(Jhistory(iter-1) - Jcurrent);
        end
        
        % Save evolution
        xhistory{iter} = [ span',forall({primal_odes.x},'mean')];
        uhistory{iter} = [ span',u]; 
        error_history(iter) = error_value;
        Jhistory(iter) = Jcurrent;

    end
    %% Warring
    if MaxIter == iter  
        warning('The maximum iteration has been reached. Convergence may not have been achieved')
    end
    %%
    iCPD.addata.xhistory = xhistory(1:(iter-1));
    iCPD.addata.uhistory = uhistory(1:(iter-1));
    iCPD.addata.error_history = error_history(1:(iter-1));
    iCPD.addata.time_execution = toc;
    iCPD.addata.Jhistory = Jhistory(1:(iter-1));
    %%
    function xt_valid(xt)
        [nrow, ncol] = size(xt);
        if nrow ~= iCPD.N ||ncol~=1
           error(['The xt, target state must have a dimension: [',num2str(iCPD.N),'x1].', ...
                   ' Your targer have a dimension: [',num2str(nrow),'x',num2str(ncol),']']);
        end
    end
end

