clearvars; clc; close all;

root = fileparts(mfilename('fullpath'));
addpath(root);
p = parameters();

assert(exist('quadprog','file') == 2, ...
    'This implementation requires quadprog from MATLAB Optimization Toolbox.');

results = cell(numel(p.model.degrees),1);
for i = 1:numel(p.model.degrees)
    D = p.model.degrees(i);
    fprintf('Running D = %d ...\n',D);
    results{i} = simulate_case(D,p);
end

summaryTable = results{1}.metrics;
segmentTable = results{1}.segmentMetrics;
for i = 2:numel(results)
    summaryTable = [summaryTable; results{i}.metrics]; %#ok<AGROW>
    segmentTable = [segmentTable; results{i}.segmentMetrics]; %#ok<AGROW>
end

disp('Closed-loop comparison:');
disp(summaryTable);
disp('Per-command comparison:');
disp(segmentTable);

if p.output.save
    if ~exist(p.output.folder,'dir')
        mkdir(p.output.folder);
    end
    writetable(summaryTable,fullfile(p.output.folder,'summary_metrics.csv'));
    writetable(segmentTable,fullfile(p.output.folder,'segment_metrics.csv'));
    save(fullfile(p.output.folder,'simulation_results.mat'), ...
        'p','results','summaryTable','segmentTable');
end

if p.output.makePlots
    plot_results(results,p);
end
