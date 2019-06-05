function Pnew = GetNumericalAdjoint(iCP,~,Ynew)
%GETNUMERICALADJOINT Summary of this function goes here
%   Detailed explanation goes here
    iCP.Adjoint.dynamics.InitialCondition = iCP.Adjoint.FinalCondition(Ynew(end,:));
    [~ , Pnew] = solve(iCP.Adjoint.dynamics);
    Pnew = flipud(Pnew); 
        
end
