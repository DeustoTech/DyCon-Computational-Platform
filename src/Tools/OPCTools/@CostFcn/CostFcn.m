classdef CostFcn < handle
    %COSTFCN is a structure where save the functions handles of total cost.
    
    
    properties
        PathCostFcn      casadi.Function
        FinalCostFcn     casadi.Function
        FinalCostGradients FinalCostGradients = FinalCostGradients
        PathCostGradients  PathCostGradients = PathCostGradients
    end
    
    methods
        function obj = CostFcn(PathCostFcn,FinalCostFcn)
            %COSTFCN 
            obj.PathCostFcn  = PathCostFcn;
            obj.FinalCostFcn = FinalCostFcn;    
                      
        end
        

    end
end

