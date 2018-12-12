classdef ControlProblem < handle
    %% Control Problem Class
    properties (SetAccess = immutable)
        Jfun 
        ode 
        

    end
    %%
    properties (Dependent = true)
        T
        dt
        UOptimal 
    end
    %%
    properties (Hidden)
        precision
        P
        adjoint
        dH_du
        %%
        Jhistory
        yhistory
        uhistory
        iter
        time
        dimension

    end
    
     
    methods
        function obj = ControlProblem(iode,Jfun,varargin)
        % name: GradientMethod
        % description: Metodo de Es
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
        %       dimension: [length(iCP.tline)]
        %       default:

            p = inputParser;
            
            addRequired(p,'iode');
            addRequired(p,'JFunctional');
                    
            addOptional(p,'T',[])
            addOptional(p,'dt',[])
            
            parse(p,iode,Jfun,varargin{:})
            
            obj.ode          = copy(iode);
            obj.Jfun         = copy(Jfun);
            
           if isempty(obj.T) 
                if Jfun.T ~= iode.T
                    warning('The parameter T (final time), is different in Jfunction and ODE problem. We use ODE.T for all.')
                end
                Jfun.T = iode.T;
           end
           if isempty(obj.dt) 
                if Jfun.dt ~= iode.dt
                    warning('The parameter dt (step time), is different in Jfunction and ODE problem. We use ODE.dt for all.')
                end
                Jfun.dt = iode.dt;
           end
           
            GetAdjointProblem(obj);
            GetGradient(obj)
        end
        
        
        function Uopt = get.UOptimal(obj)
            if ~isempty(obj.uhistory)
                Uopt = obj.uhistory{end};
            else
                Uopt = [];
            end
        end
        
        function T = get.T(obj)
            T = obj.ode.T;
        end
        function dt = get.dt(obj)
            dt = obj.ode.dt;
        end
        
    end
end

