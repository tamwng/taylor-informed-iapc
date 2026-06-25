function xNext = plant_step(x,u,p)
Ts = p.plant.Ts;

switch lower(p.plant.integrator)
    case 'rk4'
        h = Ts/p.plant.rk4Substeps;
        xNext = x;
        for j = 1:p.plant.rk4Substeps
            k1 = plant_dynamics(xNext,u,p);
            k2 = plant_dynamics(xNext + 0.5*h*k1,u,p);
            k3 = plant_dynamics(xNext + 0.5*h*k2,u,p);
            k4 = plant_dynamics(xNext + h*k3,u,p);
            xNext = xNext + h*(k1 + 2*k2 + 2*k3 + k4)/6;
        end

    case 'euler'
        xNext = x + Ts*plant_dynamics(x,u,p);

    otherwise
        error('Unknown plant integrator: %s',p.plant.integrator);
end
end
