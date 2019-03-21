  function GetSymbolicalAdjointProblem(obj)
% description: This method adds the problem adjoint to the Control Problem object, since we have
%               $$ \\dot{\\textbf{Y}} = f(\\textbf{Y},t) $$ 
%               and the functional
%               $$ J = \\Psi(\\textbf{Y}(T)) + \\int_{0}^T L(\\textbf{Y},U,t)dt $$ 
%               we can create the Hamiltonian 
%               $$ H = L + P*F $$
%               where $\\textbf{P} = [p_1 p_2 p_3 ... ]^T$ . So according to the principle of the maximum of pontriagin,
%               we can calculate the attached problems through the formulas
%               $$ \\frac{d\\textbf{P}}{dt} = \\vec{\\nabla}_{Y} H = 
%               (\\frac{\\partial H}{ \\partial y_1},\\frac{\\partial H}{ \\partial y_2},...)$$
%               with the final time condition
%               $$ \\textbf{P}(T) = 
%               (\\frac{\\partial \\Psi}{ \\partial y_1},\\frac{\\partial \\Psi}{ \\partial y_2},...)$$
% little_description: Method capable of obtaining the attached problem and its final condition.
% autor: JOroya
% MandatoryInputs:   
%    iCP: 
%        name: Control Problem
%        description: Control problem object
%        class: ControlProblem
%        dimension: [1x1]

    Jfun   = obj.J;
    iode   = obj.ode;
    L      = Jfun.L.Symbolic;
    %% Creamos las variables simbolica 
    symU   = iode.Control.Symbolic;
    symY   = iode.StateVector.Symbolic;
    t      = iode.symt;
    symP  =  sym('p', [1 length(symY)]);
    
    % H_y = L_y + p*f_y
    if obj.ode.lineal
        Lu = gradient(L,symY);
        if  sum(gradient(L,symY)) == sym(0)
            obj.adjoint.ode = ode('A',iode.A);
        else
            dP_dt = Lu + iode.A*symP.';
            % Convertimos la expresion a una funcion simbolica
            % dP_dt(t,  x1,...,xn,  u1,...,um,  p1,...,pn)
            Control = [symY.' symU.'].';
            State   = symP.';
            obj.adjoint.ode = ode(dP_dt,State,Control);
        end
    else
         %% Hamiltoniano
        H = obj.hamiltonian;
        %% Obtenemos el Adjunto
        % Creamos el problema adjunto  en simbolico
        dP_dt = gradient(formula(H),symY);  
        % Convertimos la expresion a una funcion simbolica
        % dP_dt(t,  x1,...,xn,  u1,...,um,  p1,...,pn)
        Control = [symY.' symU.'].';
        State   = symP.';
        obj.adjoint.ode = ode(dP_dt,State,Control);
        % Pasamos esta funcion a una function_handle
    end



  end
  
  