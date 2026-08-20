function tests = test_repository
tests = functiontests(localfunctions);
end


function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
testCase.TestData.root = root;
end


function teardownOnce(~)
close all force;
end


function testStructuredExponents(testCase)
expected = [1 0; 0 1; 3 0; 2 1; 0 3; ...
            5 0; 4 1; 2 3; 0 5];
verifyEqual(testCase,structured_exponents(5),expected);
counts = arrayfun(@(D) size(structured_exponents(D),1),[1 3 5 7]);
verifyEqual(testCase,counts,[2 5 9 14]);
end


function testTaylorFeatureDerivatives(testCase)
exponents = structured_exponents(7);
x = 0.23;
u = -0.31;
h = 1e-6;
[~,dphidx,dphidu] = taylor_features(x,u,exponents);
phiXPlus = taylor_features(x+h,u,exponents);
phiXMinus = taylor_features(x-h,u,exponents);
phiUPlus = taylor_features(x,u+h,exponents);
phiUMinus = taylor_features(x,u-h,exponents);
verifyLessThan(testCase,max(abs(dphidx-(phiXPlus-phiXMinus)/(2*h))),1e-7);
verifyLessThan(testCase,max(abs(dphidu-(phiUPlus-phiUMinus)/(2*h))),1e-7);
end


function testAnalyticalForwardEulerJacobian(testCase)
p = parameters();
x = 0.21;
u = -0.17;
h = 1e-6;
[Afe,Bfe] = analytical_fe_jacobian(x,u,p);
forwardEuler = @(xx,uu) xx + p.plant.Ts*plant_dynamics(xx,uu,p);
numericA = (forwardEuler(x+h,u)-forwardEuler(x-h,u))/(2*h);
numericB = (forwardEuler(x,u+h)-forwardEuler(x,u-h))/(2*h);
verifyEqual(testCase,Afe,numericA,'AbsTol',1e-9);
verifyEqual(testCase,Bfe,numericB,'AbsTol',1e-9);
end


function testRlsUpdate(testCase)
theta = zeros(2,1);
P = 2*eye(2);
phi = [1;2];
y = 3;
lambda = 1;
L = P/lambda;
v = L*phi;
expectedP = L - (v*v.')/(1 + phi.'*v);
expectedTheta = theta + expectedP*phi*y;
[actualTheta,actualP,error,prediction] = ...
    rls_update(theta,P,phi,y,lambda);
verifyEqual(testCase,actualP,expectedP,'AbsTol',1e-14);
verifyEqual(testCase,actualTheta,expectedTheta,'AbsTol',1e-14);
verifyEqual(testCase,error,3,'AbsTol',1e-14);
verifyEqual(testCase,prediction,0,'AbsTol',1e-14);
end


function testMpcInputIndexing(testCase)
p = parameters();
p.mpc.N = 2;
p.mpc.Q = ones(2,1);
p.mpc.R = 0.5;
p.constraints.xMax = 10;
p.constraints.uMax = 10;
[uNext,info] = solve_mpc_qp(0,0,1,1,0,[0;1],p);
verifyGreaterThan(testCase,info.exitflag,0);
verifyEqual(testCase,uNext,2/3,'AbsTol',1e-8);
verifyLessThanOrEqual(testCase,info.maxSlack,1e-6);
end


function testMpcStateSlackIndexing(testCase)
p = parameters();
p.mpc.N = 2;
p.mpc.Q = zeros(2,1);
p.mpc.R = 1;
p.mpc.S = 1;
p.constraints.xMax = 0.75;
p.constraints.uMax = 10;
[uNext,info] = solve_mpc_qp(2,0,1,0,0,[0;0],p);
verifyGreaterThan(testCase,info.exitflag,0);
verifyEqual(testCase,uNext,0,'AbsTol',1e-10);
verifyEqual(testCase,info.maxSlack,1.25,'AbsTol',1e-8);
end


function testReferenceHorizonIndexing(testCase)
p = parameters();
p.mpc.N = 3;
p.reference.preview = true;
currentK = p.id.Nid - 1;
preview = mpc_reference_horizon(currentK,p);
verifyEqual(testCase,preview,reference_signal(currentK+(1:3),p), ...
    'AbsTol',1e-14);
p.reference.preview = false;
held = mpc_reference_horizon(currentK,p);
verifyEqual(testCase,held,reference_signal(currentK,p)*ones(1,3), ...
    'AbsTol',1e-14);
end


function testCanonicalMetricsAndQpFailures(testCase)
p = parameters();
p.output.save = false;
p.output.makePlots = false;
p.output.verbose = false;
[~,summary,segments] = run_experiment(p);
expectedSummary = readtable(fullfile(testCase.TestData.root, ...
    'results','summary_metrics.csv'));
expectedSegments = readtable(fullfile(testCase.TestData.root, ...
    'results','segment_metrics.csv'));
verifyEqual(testCase,table2array(summary),table2array(expectedSummary), ...
    'AbsTol',1e-10);
verifyEqual(testCase,table2array(segments),table2array(expectedSegments), ...
    'AbsTol',1e-10);
verifyEqual(testCase,summary.QPFailures,zeros(4,1));
verifyEqual(testCase,summary.MaxInputViolation,zeros(4,1));
verifyGreaterThan(testCase,summary.MaxStateViolation,zeros(4,1));
end


function testTrackingErrorAxisIsLogarithmic(testCase)
loaded = load(fullfile(testCase.TestData.root,'results', ...
    'simulation_results.mat'),'results');
p = parameters();
p.output.save = false;
p.output.figureVisible = 'off';
figures = plot_results(loaded.results,p);
trackingAxes = findobj(figures.trackingError,'Type','axes');
verifyNotEmpty(testCase,trackingAxes);
verifyTrue(testCase,all(arrayfun(@(ax) strcmp(ax.YScale,'log'), ...
    trackingAxes)));
close all force;
end


function testExperimentManifest(testCase)
manifestPath = fullfile(testCase.TestData.root,'experiment_manifest.json');
manifest = jsondecode(fileread(manifestPath));
verifyEqual(testCase,manifest.experiment.prediction_horizon,8);
verifyEqual(testCase,manifest.experiment.integrator,'rk4');
verifyEqual(testCase,manifest.experiment.degrees,[1;3;5;7]);
verifyEqual(testCase,manifest.experiment.coefficient_counts,[2;5;9;14]);
verifyEqual(testCase,manifest.expected_results.total_qp_failures,0);
end
