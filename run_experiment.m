function [results,summaryTable,segmentTable,figures] = run_experiment(p)
%RUN_EXPERIMENT Execute the canonical degree sweep for a parameter struct.

arguments
    p (1,1) struct
end

assert(exist('quadprog','file') == 2, ...
    'This implementation requires quadprog from MATLAB Optimization Toolbox.');

results = cell(numel(p.model.degrees),1);
for i = 1:numel(p.model.degrees)
    D = p.model.degrees(i);
    if p.output.verbose
        fprintf('Running D = %d ...\n',D);
    end
    results{i} = simulate_case(D,p);
end

summaryCells = cellfun(@(s) s.metrics,results,'UniformOutput',false);
segmentCells = cellfun(@(s) s.segmentMetrics,results,'UniformOutput',false);
summaryTable = vertcat(summaryCells{:});
segmentTable = vertcat(segmentCells{:});

if p.output.verbose
    disp('Closed-loop comparison:');
    disp(summaryTable);
    disp('Per-amplitude comparison:');
    disp(segmentTable);
end

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
    figures = plot_results(results,p);
else
    figures = struct();
end
end
