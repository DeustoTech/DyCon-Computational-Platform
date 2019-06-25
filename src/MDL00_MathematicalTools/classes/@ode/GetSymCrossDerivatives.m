function  GetSymCrossDerivatives(obj)
%GETSYMCROSSDERIVATIVE Summary of this function goes here
%   Detailed explanation goes here
%%
sY = obj.StateVector.Symbolic;
sU = obj.Control.Symbolic;
st = obj.symt;
%
dF_dU = obj.Derivatives.Control.Sym;
dF_dY = obj.Derivatives.State.Sym;
%%
d2F_dU2  = jacobian(dF_dU(:),sU);
obj.Derivatives.ControlControl.Sym = d2F_dU2;
obj.Derivatives.ControlControl.Num = matlabFunction(d2F_dU2,'Vars',{st,sY,sU});
%
d2F_dY2  = jacobian(dF_dY(:),sY);
obj.Derivatives.StateState.Sym = d2F_dY2;
obj.Derivatives.StateState.Num = matlabFunction(d2F_dY2,'Vars',{st,sY,sU});
%
d2F_dUdY = jacobian(dF_dU(:),sY);
obj.Derivatives.StateControl.Sym = d2F_dUdY;
obj.Derivatives.StateControl.Num = matlabFunction(d2F_dUdY,'Vars',{st,sY,sU});

end

