function p = parameters()
root = fileparts(mfilename('fullpath'));

p.plant.a = 0.5;
p.plant.b = 1.5;
p.plant.Ts = 0.1;
p.plant.x0 = 0;
p.plant.integrator = 'rk4';
p.plant.rk4Substeps = 1;

p.constraints.xMax = 1;
p.constraints.uMax = 1;

p.model.degrees = [1 3 5 7];

p.mpc.N = 15;
p.mpc.Q = ones(p.mpc.N,1);
p.mpc.Q(end) = 10;
p.mpc.R = 5e-2;
p.mpc.S = 1e5;

p.rls.lambda = 1;
p.rls.P0Scale = 1e4;

p.id.Nid = 30;
p.id.levels = [0 0.1 -0.1 0.2 -0.2];

p.reference.Kr = 150;
p.reference.commands = [0.3 0.6 0.9 -0.9 0];
p.reference.preview = true;

p.simulation.K = p.id.Nid + numel(p.reference.commands)*p.reference.Kr;
p.metrics.ssWindow = 25;
p.plot.jacobianDegree = 5;

p.output.makePlots = true;
p.output.save = true;
p.output.folder = fullfile(root,'results');
end
