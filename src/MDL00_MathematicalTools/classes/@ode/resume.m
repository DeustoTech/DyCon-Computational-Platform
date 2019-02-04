function resume(iode)
% description: Constructor the ecuacion diferencial
% autor: JOroya
% MandatoryInputs:   
%   DynamicEquation: 
%       description: simbolic expresion
%       class: Symbolic
%       dimension: [1x1]
%   VectorState: 
%       description: simbolic expresion
%       class: Symbolic
%       dimension: [1x1]
%   Control: 
%       description: simbolic expresion
%       class: Symbolic
%       dimension: [1x1]
% OptionalInputs:
%   InitialControl:
%       name: Initial Control 
%       description: matrix 
%       class: double
%       dimension: [length(iCP.tspan)]
%       default:   empty   
tab = '     ';

switch iode.Type
    case 'InitialCondition'
        condition = 'Y(0) = ';
    case 'FinalCondition'
        condition = 'Y(T) = ';
end

display([newline, ...
         tab,'Dynamics:',newline,newline, ...
         tab,tab,'Y''(t,Y,U) = ',char(iode.Dynamic.Symbolic), ...
         newline,newline, ...
         tab,tab,'t in [0,',num2str(iode.FinalTime),']  with condition: ',condition,char(join(string(iode.Condition),' ')),newline])
         
end

