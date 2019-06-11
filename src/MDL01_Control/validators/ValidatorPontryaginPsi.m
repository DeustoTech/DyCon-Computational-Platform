function ValidatorPontryaginPsi(obj)
%VALIDATORPONTRYAGINPSI Summary of this function goes here
%   Detailed explanation goes here
    example = ['For Example:',newline, ...
     '          Psi = @(T,Y) Y.^2'];

    if ~isa(obj,'function_handle') && ~isempty(obj)
       error(['The terminal cost,Psi, must be function handle. ',example]) 
    elseif nargin(obj)~=2
       error([newline,'The Dynamics equation must have 2 arguments. ',example])
    end
    
end

