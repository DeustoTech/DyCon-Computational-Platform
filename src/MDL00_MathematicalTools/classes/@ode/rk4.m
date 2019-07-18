function [tline,yline] = rk4(iode)
% description: The ode class, if only de organization of ode.
%               The solve of this class is the RK family.
% autor: JOroya
% OptionalInputs:
%   DynamicEquation: 
%       description: simbolic expresion
%       class: Symbolic
%       dimension: [1x1]
%   StateVector: 
%       description: StateVector
%       class: Symbolic
%       dimension: [1x1]
%   Control: 
%       description: simbolic expresion
%       class: Symbolic
%       dimension: [1x1]
%   A: 
%       description: simbolic expresion
%       class: matrix
%       dimension: [1x1]
%   B: 
%       description: simbolic expresion
%       class: matrix
%       dimension: [1x1]            
%   InitialControl:
%       name: Initial Control 
%       description: matrix 
%       class: double
%       dimension: [length(iCP.tspan)]
%       default:   empty   
    tline = iode.tspan;
    yline = zeros(length(tline),length(iode.StateVector.Symbolic));
    yline(1,:) = iode.InitialCondition;
    u0    = iode.Control.Numeric;
    odefunControl = iode.DynamicEquation.Numeric;
    
    ufun = @(t) interp1(tline,u0,t)';
    odefun = @(t,y) odefunControl(t,y,ufun(t));
    for i=1:length(tline)-1
        h = tline(i+1)-tline(i);
        
        k_1 = odefun(tline(i),yline(i,:)');
        k_2 = odefun(tline(i)+0.5*h,yline(i,:)'+0.5*h*k_1);
        k_3 = odefun((tline(i)+0.5*h),yline(i,:)'+0.5*h*k_2);
        k_4 = odefun((tline(i)+h),(yline(i,:)'+k_3*h));
    
        yline(i+1,:) = yline(i,:) + (1/6)*(k_1+2*k_2+2*k_3+k_4)'*h;
    end        
end
