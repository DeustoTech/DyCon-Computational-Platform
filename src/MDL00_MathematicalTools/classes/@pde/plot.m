function plot(iode,varargin)
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

    p = inputParser;
    addRequired(p,'iode');
    addOptional(p,'Parent',[])
    
    
    parse(p,iode,varargin{:})
    
    Parent = p.Results.Parent;
    
    if isempty(Parent)
        f = figure;
        Parent = axes('Parent',f);        
    end
        
       
        surf(iode.StateVector.Numeric)
        Parent.XLabel.String = 'space';
        Parent.YLabel.String = 'time';
        Parent.Title.String = 'Y(x,t)';

end

