function report = verify_reproduction()
%VERIFY_REPRODUCTION Reproduce in a temporary folder and verify artifacts.

root = fileparts(mfilename('fullpath'));
runFolder = [tempname '_taylor_iapc'];
mkdir(runFolder);
cleanup = onCleanup(@() cleanup_temporary_run(runFolder));

report = reproduce_results(runFolder);
report.comparison = verify_results(runFolder,fullfile(root,'results'),1e-10);

expectedFiles = {'summary_metrics.csv','segment_metrics.csv', ...
    'simulation_results.mat','state_tracking_D1_D5.png', ...
    'tracking_error_log.png','per_amplitude_abs_error.png'};
for i = 1:numel(expectedFiles)
    assert(isfile(fullfile(runFolder,expectedFiles{i})), ...
        'Missing reproduced artifact: %s',expectedFiles{i});
end

figureFiles = {'state_tracking_D1_D5.png','tracking_error_log.png', ...
    'per_amplitude_abs_error.png'};
for i = 1:numel(figureFiles)
    generatedPixels = imread(fullfile(runFolder,figureFiles{i}));
    baselinePixels = imread(fullfile(root,'results',figureFiles{i}));
    assert(isequal(generatedPixels,baselinePixels), ...
        'Rendered pixels differ from the baseline: %s',figureFiles{i});
end

assert(report.qpFailures == 0,'The canonical run contains QP failures.');
trackingAxes = findobj(report.figures.trackingError,'Type','axes');
assert(~isempty(trackingAxes) && ...
    all(arrayfun(@(ax) strcmp(ax.YScale,'log'),trackingAxes)), ...
    'The tracking-error figure is not logarithmic.');

fprintf('Reproduction verified within an absolute tolerance of 1e-10.\n');
fprintf('Rendered figure pixels match the committed baseline exactly.\n');
end


function cleanup_temporary_run(runFolder)

close all force;
if isfolder(runFolder)
    rmdir(runFolder,'s');
end
end
