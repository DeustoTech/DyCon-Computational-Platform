classdef OptimalControl < handle & matlab.mixin.SetGet & matlab.mixin.Copyable
% description: "This class is able to solve optimization problems of a function restricted to an ordinary equation.
%               This scheme is used to solve optimal control problems in which the functional derivative is calculated. 
%               <strong>OptimalControl</strong> class has methods that help us find optimal control as well as obtaining 
%               the attached problem and it's derivative form, 
%               in both Symbolic and numerical versions."
% long:  This class is able to solve optimal control problems. Optimal control refers to the problem of finding a control law
%           for a given system such that a certain optimality criterion is achieved. The essential features of an optimal control problem are 
%               <ul>
%               <li> a cost functional to be minimized;</li>
%               <li> an initial/boundary value problem for a differential equation describing the motion, in order to determine the state of the system;</li>
%               <li> a control function;</li>
%               <li> eventual constraints that have to be obeyed.</li>
%               </ul>
%               The control may be freely chosen within the given constraints, while the state is uniquely determined by the differential equation and the initial conditions.
%               We have to choose the control in such a way that the cost function is minimized. This class allows treating general optimal control problems in the form
%               $$ \begin{equation*}
%                   \min_{u\in\mathcal{U}} J,
%               \end{equation*} $$
%                in which the objective functional $J$ is defined as
%                $$ \begin{equation*}
%                   J=\Psi (x(T))+\int _{0}^{T}\mathcal{L}(x(t),u(t)),dt
%               \end{equation*} $$
%               and where $x$ is the state of a dynamical system with input $u\in\mathcal{U}$, the set of admissible controls 
%               $$\begin{equation*} \dot {x}=f(x,u),\quad x(0)=x_{0},\quad
%               u(t)\in\mathcal {U},\quad t\in [0,T]. \end{equation*}$$
%               Moreover, the class permits to choose among different methods for solving the minimization problem. At the present stage, the methods available are
%                 <ul>
%                   <li>  gradient method;</li>
%                   <li>  gradient method with adaptive descend step;</li>
%                   <li>  conjugate gradient method.</li>
%                 </ul>
    properties 
        % type: "Functional"
        % default: "none"
        % description: "This property represent the cost of optimal control"
        J        
        % type: ode
        % default: none
        % description: This property represented ordinary differential equation
        ode        
        % type: double
        % default: function_handle
        % description: The derivative of the Hamiltonian with respect to the control u 
        adjoint
        % type: double
        % default: function_handle
        % description: The derivative of the Hamiltonian with respect to the control u 
        hamiltonian
        % type: struct
        % default: none
        % description: The adjoint propertir contain the numerical function that represents the adjoint problem this struct have a two properties. The first is dP_dt and the second is P0.   
        gradient
        % type: double
        % default: none
        % description: It is an array that contains the different functional values during the execution of the optimization algorithm that has been used.
        solution
        %
        YT
    end
    
     
    methods
        function obj = OptimalControl(iode,symPsi,symL,varargin)
        % name: ControlProblem
        % description: 
        % autor: JOroya
        % MandatoryInputs:   
        %   iode: 
        %       name: Ordinary Differential Equation 
        %       description: Ordinary Differential Equation represent the constrain to minimization the functional 
        %       class: ode
        %       dimension: [1x1]
        %   Jfun: 
        %       name: functional
        %       description: Cost function to obtain the optimal control 
        %       class: Functional
        %       dimension: [1x1]        
        % OptionalInputs:
        %   T:
        %       name: Final Time 
        %       description: This parameter represent the final time of simulation.  
        %       class: double
        %       dimension: [1x1]
        %       default: iode.T 
        %   dt:
        %       name: Final Time 
        %       description: This parameter represent is the interval to interpolate the control, $u$, and state, $y$, to obtain the functional $J$ and the gradient $dH/du$
        %       class: double
        %       dimension: [1x1]
        %       default: iode.dt         
        % Outputs:
        %   obj:
        %       name: ControlProblem MATLAB
        %       description: ControlProblem MATLAB class
        %       class: ControlProblem
        %       dimension: [1x1]

            p = inputParser;
            
            addRequired(p,'iode');
            
            addRequired(p,'symPsi');
            addRequired(p,'symL');
                    
            parse(p,iode,symPsi,symL,varargin{:})
            
            t    = iode.symt;
            symU = iode.Control.Symbolic;
            symY = iode.VectorState.Symbolic;
            %% Functiona Definition
            obj.J.Psi.Symbolic  = symfun(symPsi,[t,symY.']);
            obj.J.Psi.Numeric  = matlabFunction(symPsi,'Vars',{t,symY});

            obj.J.L.Symbolic    = symfun(symL,[t,symY.',symU.']);
            obj.J.L.Numeric    = matlabFunction(symL,'Vars',{t,symY,symU});
            %% Dynamics Definition                   
            obj.ode          = copy(iode);
            %% Direccion del Gradiente
            GetGradient(obj);
            %% Calculate Adjoint of Dynamics
            GetAdjointProblem(obj);
            
        end
        
    end
end
