function dx = plant_dynamics(x,u,p)
dx = p.plant.a*sin(x)*cos(x) ...
   + p.plant.b*cos(x)^2*sin(u);
end
