function p = parameters()
root = fileparts(mfilename('fullpath'));

p.plant.a = 0.5;
p.plant.b = 1.5;
p.plant.Ts = 0.05;
p.plant.x0 = 0;
p.plant.integrator = 'rk4';
p.plant.rk4Substeps = 1;

p.constraints.xMax = 0.75;
p.constraints.uMax = 1;

p.model.degrees = [1 3 5 7];

p.mpc.N = 8;
p.mpc.Q = ones(p.mpc.N,1);
p.mpc.Q(end) = 10;
p.mpc.R = 5e-2;
p.mpc.S = 1e5;

p.rls.lambda = 1.0;
p.rls.P0Scale = 1e5;

p.id.Nid = 60;
p.id.levels = [0 0.15 -0.15 0.30 -0.30 ...
                 0.45 -0.45 0.60 -0.60];

p.reference.type = 'amp_sine';
p.reference.Kr = 300;
p.reference.frequencyHz = 0.10;
p.reference.ampLevels = [0.25 0.55 0.80 0.90 0.00];
p.reference.bias = 0;
p.reference.phase = 0;
p.reference.preview = true;

p.simulation.K = p.id.Nid + numel(p.reference.ampLevels)*p.reference.Kr;

p.metrics.ssWindow = 25;
p.plot.jacobianDegree = 5;

p.output.makePlots = true;
p.output.save = true;
p.output.folder = fullfile(root,'results');
end