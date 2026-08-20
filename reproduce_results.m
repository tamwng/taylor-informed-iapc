function report = reproduce_results(outputFolder)
%REPRODUCE_RESULTS Regenerate the canonical ACC 2027 numerical artifacts.
%
%   reproduce_results() writes to the repository's results/ directory.
%   reproduce_results(outputFolder) writes to an alternate folder, which
%   is useful for isolated verification without modifying committed files.

root = fileparts(mfilename('fullpath'));
if nargin < 1 || isempty(outputFolder)
    outputFolder = fullfile(root,'results');
end

p = parameters();
p.output.folder = outputFolder;

startedAt = datetime('now','TimeZone','UTC');
timer = tic;
[~,summaryTable,segmentTable,figures] = run_experiment(p);
elapsedSeconds = toc(timer);

report.outputFolder = outputFolder;
report.startedAtUTC = startedAt;
report.elapsedSeconds = elapsedSeconds;
report.summaryTable = summaryTable;
report.segmentTable = segmentTable;
report.qpFailures = sum(summaryTable.QPFailures);
report.figures = figures;
report.figureFiles = fieldnames(figures);

if p.output.verbose
    fprintf('Reproduction completed in %.1f seconds.\n',elapsedSeconds);
    fprintf('Artifacts: %s\n',outputFolder);
end
end
