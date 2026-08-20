function results = run_repository_tests()
%RUN_REPOSITORY_TESTS Run all automated repository validation tests.

root = fileparts(mfilename('fullpath'));
results = runtests(fullfile(root,'tests'),'IncludeSubfolders',true);
disp(table(results));
assert(all([results.Passed]),'One or more repository tests failed.');
end
