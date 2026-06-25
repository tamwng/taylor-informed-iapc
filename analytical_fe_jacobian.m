function [Afe,Bfe] = analytical_fe_jacobian(x,u,p)
Ts = p.plant.Ts;
a = p.plant.a;
b = p.plant.b;

Afe = 1 + Ts*(a*cos(2*x) - b*sin(2*x)*sin(u));
Bfe = Ts*b*cos(x)^2*cos(u);
end
