function varargout = GradientMethod(iCP,InitialControl,varargin)
    % name: GradientMethod
    % little_description: The gradient method is able to optimize the given functional, going down the gradient.
    % description: "The gradient method is able to optimize the given
    %                       functional, going down the gradient. El calculo del gradiente puede
    %                       ser de varios tipo. Por defecto la direccion y el modulo de descenso
    %                       se calcula con el gradiente conjugado
    %                       http://web.mit.edu/mitter/www/publications/2_conjugate_grad_IEEEAC.pdf"
    % autor: JOroya
    % MandatoryInputs:   
    %   iCP: 
    %       name: Control Problem
    %       description: 
    %       class: ControlProblem
    %       dimension: [1x1]
    % OptionalInputs:
    %   U0:
    %       name: Initial Control 
    %       description: matrix 
    %       class: double
    %       dimension: [length(iCP.tspan)]
    %       default: zeros
    %   MaxIter:
    %       name: Initial Control 
    %       description: matrix 
    %       class: double
    %       dimension: [1x1]
    %       default: 50
    %   tol:
    %       name: Initial Control 
    %       description: tolerance of Descent Method
    %       class: double
    %       dimension: 
    %       dimension: [1x1]
    %   tolU:
    %       name: Initial Control 
    %       description: tolerance of Descent Method
    %       class: double
    %       dimension: 
    %       dimension: [1x1]
    %   tolJ:
    %       name: Initial Control 
    %       description: tolerance of Descent Method
    %       class: double
    %       dimension: 
    %       dimension: [1x1]
    %   DescentParameters:
    %       description: Parmater of Descent Method 
    %       class: double
    %       dimension: cell
    %       default: cell.empty    
    %   Graphs:
    %       description: Parameter that indicate if the method must plot the optimization, while is calculate 
    %       class: logical
    %       dimension: [1x1]
    %       default: false        
    %   TypeGraphs:
    %       description: Type of graphs. This parameter can be 'ODE' or 'PDE' 
    %       class: string
    %       dimension: [1x1]
    %       default: 'ODE'
    %   SaveGif:
    %       name: If this parameter is true, A gif of the optimization process is created
    %       description: matrix 
    %       class: double
    %       dimension: [length(iCP.tspan)]
    %       default: false
    %   restart:
    %       description: The optimization start with U0 = iCP.UOptimal
    %       class: double
    %       dimension: [1x1]
    %       default: false
    
    
    % ======================================================
    % ======================================================
    %               PARAMETERS DEFINITION
    % ======================================================
    % ======================================================
   
    %% Control Problem Parameters
    pinp = inputParser;
    addRequired(pinp,'iControlProblem')
    addRequired(pinp,'InitialControl',@(U) InitialControlDefault(U,iCP))
    %% Method Parameter
    % ------------------------------------------------------------------------------------------------------
    % |             | Name                  | Default               |            Validator                  | 
    % ------------------------------------------------------------------------------------------------------
    addOptional(pinp,'MaxIter'              ,1000)
    addOptional(pinp,'tol'                  ,1e-6)
    addOptional(pinp,'tolU'                 ,1e-6)
    addOptional(pinp,'tolJ'                 ,1e-9)
    addOptional(pinp,'DescentAlgorithm'     ,@ConjugateDescent     ,@(alg)mustBeMember(char(alg),{'AdaptativeDescent','ConjugateDescent','ClassicalDescent'}))
    addOptional(pinp,'DescentParameters'    ,{})
    %% Graphs Parameters
    % ------------------------------------------------------------------------------------------------------
    % |             | Name     | Default   |            Validator                                          | 
    % ------------------------------------------------------------------------------------------------------
    addOptional(pinp,'GraphsFcn'   ,{@init_graphs_gradientmethod,@bucle_graphs_gradientmethod} )
    addOptional(pinp,'Graphs'   ,false )
    addOptional(pinp,'EachIter' ,5 )

    addOptional(pinp,'display'  ,'end'     ,@(display)mustBeMember(display,{'none','all','functional','end'}))
    addOptional(pinp,'SaveGif'  ,false )
    addOptional(pinp,'restart'  ,false )

    %% 
    addOptional(pinp,'StoppingCriteria',@FunctionalStopCriteria  )

    parse(pinp,iCP,InitialControl,varargin{:})

    MaxIter             = pinp.Results.MaxIter;    
    tol                 = pinp.Results.tol;
    tolU                = pinp.Results.tolU;
    tolJ                = pinp.Results.tolJ;
    Graphs              = pinp.Results.Graphs;
    GraphsFcn           = pinp.Results.GraphsFcn;
    restart             = pinp.Results.restart;
    SaveGif             = pinp.Results.SaveGif;
    DescentAlgorithm    = pinp.Results.DescentAlgorithm;
    DescentParameters   = pinp.Results.DescentParameters;
    display_parameter   = pinp.Results.display;
    EachIter            = pinp.Results.EachIter;
    % ======================================================
    % ======================================================
    %                   INIT PROGRAM
    % ======================================================
    % ======================================================
    %% Comprobe Numerical Derivatives
    %

    %% Comprobamos los solver
    % Set dynamics <---> adjoint 
    iCP.Adjoint.Dynamics.Nt        = iCP.Dynamics.Nt;
    iCP.Adjoint.Dynamics.FinalTime = iCP.Dynamics.FinalTime;

    if iCP.Dynamics.lineal == iCP.Adjoint.Dynamics.lineal
        iCP.Adjoint.Dynamics.SolverParameters = iCP.Dynamics.SolverParameters;
        iCP.Adjoint.Dynamics.Solver = iCP.Dynamics.Solver;    
    end   
    %% Creamos un solucion vacia
    iCP.Solution = solution;

    iCP.Solution.Yhistory = cell(1,MaxIter);
    iCP.Solution.ControlHistory = cell(1,MaxIter);
    iCP.Solution.dJhistory = cell(1,MaxIter);

    iCP.Solution.Jhistory = zeros(1,MaxIter);
    %
    iCP.Solution.ControlHistory{1} = InitialControl;
    
    %%
    InitGraphsFcn = GraphsFcn{1};
    IterGraphsFcn = GraphsFcn{2};

    %%
    if restart
        if ~isempty(iCP.Solution.UOptimal)
            InitialControl = iCP.Solution.UOptimal;
        else
            if ~strcmp(display_parameter,'none')
                warning('The parameter restart need a previus execution.')
            end
        end
    end
    tic;
    
    if Graphs 
        % initial axes 

        axes = InitGraphsFcn(iCP);
    end
    
    %% Clean the persiten variable LengthStepMemory
    clear(char(DescentAlgorithm))
    % ClassicalDescent
    % ConjugateGradientDescent
    % ConjugateGradienDescent
    
    SolverChar = char(iCP.Dynamics.Solver);
    
    for iter = 1:MaxIter
        % Create a funtion u(t) 
        % Update Control
        [Unew, Ynew,Pnew,Jnew,dJnew,erroriter,stop] = DescentAlgorithm(iCP,tol,tolU,tolJ,DescentParameters{:});
        if strcmp(SolverChar,'euleri')
            Unew(end,:) = 0;
        end
        % Save history of optimization
        iCP.Solution.ControlHistory{iter}  = Unew;
        iCP.Solution.Yhistory{iter}  = Ynew;
        iCP.Solution.Phistory{iter}  = Pnew;
        iCP.Solution.Jhistory(iter)  = Jnew;
        iCP.Solution.dJhistory{iter} = dJnew;
        iCP.Solution.Ehistory(iter)     = erroriter;
        
        if  1+mod(iter,EachIter) == 1 || stop
            switch display_parameter
                case 'all'
                display(     "error = "        + num2str(erroriter,'%d')        + ...
                         " | Functional = "    + num2str(Jnew,'%d')         + ...
                         " | norm(Gradient) = "+ num2str(norm(dJnew),'%d')  + ...
                         " | norm(U) = "       + num2str(norm(Unew),'%d')   + ...
                         " | iter = "          + iter)
                case 'functional'
                display(     "error = "        + num2str(erroriter,'%d')        + ...
                         " | Functional = "    + num2str(Jnew,'%d')         + ...
                         " | iter = "          + iter)
            end
                             % Stopping Criteria
            if Graphs   
                % plot the graphical convergence 
                IterGraphsFcn(axes,iCP,iter)
            end

        end
        if stop
              break 
        end
    end
    
    
    if iter == MaxIter && ~strcmp(display_parameter,'none') 
        warning('Max iteration number reached!!')
    end
    
    iCP.Solution.precision      = erroriter;
    iCP.Solution.ControlHistory = iCP.Solution.ControlHistory(1:iter);
    iCP.Solution.Jhistory       = iCP.Solution.Jhistory(1:iter);
    iCP.Solution.dJhistory      = iCP.Solution.dJhistory(1:iter);
    iCP.Solution.Yhistory       = iCP.Solution.Yhistory(1:iter);

    iCP.Solution.iter = iter;
    iCP.Solution.time = toc; 
    
    if ~strcmp(display_parameter,'none')
        resume(iCP.Solution)
    end
    
    switch nargout
        case 1
            varargout{1} = iCP.Solution.ControlHistory{end};
        case 2 
            varargout{1} = iCP.Solution.ControlHistory{end};
            varargout{2} = iCP.Solution.Jhistory(end);
        case 3
            varargout{1} = iCP.Solution.ControlHistory{end};
            varargout{2} = iCP.Solution.Jhistory(end);          
            varargout{3} = iCP.Solution.Yhistory{end};            

    end
    
    %% 
    function InitialControlDefault(U0,iCP)
        mustBeNumeric(U0)
        
        [Nt,NControl] = size(U0);
        
        
        if isa(iCP,'InverseProblem')
            if iCP.Dynamics.StateDimension ~=  NControl
                error(newline+"   The Initial Condition seed must be a matrix: [1x"+iCP.Dynamics.StateDimension+"]" + newline)
            end            
        else
            if iCP.Dynamics.ControlDimension ~=  NControl
                error(newline+"   The Initial Control must be a matrix: ["+iCP.Dynamics.Nt+"x"+iCP.Dynamics.ControlDimension+"]" + newline)
            end
            if iCP.Dynamics.Nt ~=  Nt
                error(newline+"   The Initial Control must be a matrix: ["+iCP.Dynamics.Nt+"x"+iCP.Dynamics.ControlDimension+"]" + newline)
            end
        end
    end
end




