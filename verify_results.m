function comparison = verify_results(candidateFolder,baselineFolder,tolerance)
%VERIFY_RESULTS Compare generated CSV tables with the committed baseline.

if nargin < 2 || isempty(baselineFolder)
    root = fileparts(mfilename('fullpath'));
    baselineFolder = fullfile(root,'results');
end
if nargin < 3 || isempty(tolerance)
    tolerance = 1e-10;
end

files = {'summary_metrics.csv','segment_metrics.csv'};
comparison = struct();

for i = 1:numel(files)
    filename = files{i};
    candidate = readtable(fullfile(candidateFolder,filename));
    baseline = readtable(fullfile(baselineFolder,filename));

    assert(isequal(candidate.Properties.VariableNames, ...
        baseline.Properties.VariableNames), ...
        'Column mismatch in %s.',filename);
    assert(isequal(size(candidate),size(baseline)), ...
        'Table-size mismatch in %s.',filename);

    difference = abs(table2array(candidate) - table2array(baseline));
    maxAbsoluteDifference = max(difference,[],'all');
    assert(maxAbsoluteDifference <= tolerance, ...
        '%s differs from baseline by %.3g (tolerance %.3g).', ...
        filename,maxAbsoluteDifference,tolerance);

    field = erase(filename,'.csv');
    comparison.(field).maxAbsoluteDifference = maxAbsoluteDifference;
    comparison.(field).tolerance = tolerance;
    comparison.(field).passed = true;
end
end
