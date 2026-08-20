function [Afe,Bfe] = analytical_fe_jacobian(x,u,p)
%ANALYTICAL_FE_JACOBIAN Optional forward-Euler diagnostic reference.
% These derivatives are not used to propagate the RK4-simulated plant or
% to construct the MPC predictor.

Ts = p.plant.Ts;
a = p.plant.a;
b = p.plant.b;

Afe = 1 + Ts*(a*cos(2*x) - b*sin(2*x)*sin(u));
Bfe = Ts*b*cos(x)^2*cos(u);
end
