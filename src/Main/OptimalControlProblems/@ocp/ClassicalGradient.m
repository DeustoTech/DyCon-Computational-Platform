function varargout = ClassicalGradient(iocp,ControlGuess,varargin)
%GRADIENTDESCENT 

    p = inputParser;

    SetDefaultGradientOptions(p)
    
    addOptional(p,'LengthStep',1e-4)

    parse(p,iocp,ControlGuess,varargin{:})

    %%
    %% Parameters
    LengthStep = p.Results.LengthStep;
    MaxIter    = p.Results.MaxIter;
    tol        = p.Results.tol;
    EachIter   = p.Results.EachIter;
    %%
    if ~iocp.DynamicSystem.HasSolver
        warning('The object ode doesn''t have solver. By default, we SetIntegrator = Euler  ')
        SetIntegrator(iocp.DynamicSystem,'Euler')
    end
    if ~iocp.HasGradients
        PreIndirectMethod(iocp)
    end
    %% Classical Gradient
    Ut = ControlGuess;
    for iter = 1:MaxIter
        % solve Primal System with current control
        [dU,Jc,Xsol] = Control2ControlGradient(iocp,Ut);
        % Update Control
        Ut = Ut - LengthStep*dU;
        % Compute Error
        error = norm_fro(dU);
        % Look if error is small 
        if full(error) < tol
            break
        end
        %
        if ~isempty(iocp.TargetState)
            TargetDistance = norm(iocp.TargetState  - Xsol(:,end));
        else 
            TargetDistance = nan;
        end
        if mod(iter,EachIter) == 0
        fprintf("iteration: "    + num2str(iter,'%.3d')             +  ...
                " | error: "     + num2str(full(error),'%10.3e')          +  ...
                " | LengthStep: "+ num2str(LengthStep,'%10.3e')     +  ...
                " | J: "         + num2str(full(Jc),'%10.3e')             +  ...
                " | Distance2Target: " + num2str(full(TargetDistance))    +  ...
                " \n"  )
        end
    end

    switch nargout
        case 1
            varargout{1} = Ut;
        case 2
            varargout{1} = Ut;
            varargout{2} = Xsol;
    end
end

