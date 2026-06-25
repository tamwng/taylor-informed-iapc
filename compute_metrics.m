function [summary,segments] = compute_metrics(result,p)
k = result.k;
e = result.x - result.reference;
controlMask = k >= p.id.Nid;

rmse = sqrt(mean(e(controlMask).^2));
mae = mean(abs(e(controlMask)));
maxAbsError = max(abs(e(controlMask)));

segmentStart = p.id.Nid + (0:numel(p.reference.commands)-1)*p.reference.Kr;
segmentStop = segmentStart + p.reference.Kr;
ssErrors = zeros(0,1);
segmentRows = cell(numel(segmentStart),1);

for j = 1:numel(segmentStart)
    mask = k >= segmentStart(j) & k < segmentStop(j);
    segmentError = e(mask);
    segmentInput = result.u(mask);

    ssStart = max(segmentStart(j),segmentStop(j)-p.metrics.ssWindow);
    ssMask = k >= ssStart & k < segmentStop(j);
    currentSSError = e(ssMask);
    ssErrors = [ssErrors; currentSSError(:)]; %#ok<AGROW>

    if numel(segmentInput) > 1
        segmentTV = sum(abs(diff(segmentInput)));
    else
        segmentTV = 0;
    end

    segmentRows{j} = table( ...
        result.D,p.reference.commands(j), ...
        sqrt(mean(segmentError.^2)), ...
        mean(currentSSError),mean(abs(currentSSError)),segmentTV, ...
        'VariableNames',{'Degree','Command','RMSE', ...
        'SteadyStateBias','SteadyStateAbsError','InputVariation'});
end
segments = vertcat(segmentRows{:});

controlInput = result.u(controlMask);
if numel(controlInput) > 1
    totalVariation = sum(abs(diff(controlInput)));
else
    totalVariation = 0;
end

maxStateViolation = max([0; abs(result.x(:))-p.constraints.xMax]);
maxInputViolation = max([0; abs(result.u(:))-p.constraints.uMax]);

validSlack = result.qpMaxSlack(~isnan(result.qpMaxSlack));
if isempty(validSlack)
    maxPredictedSlack = NaN;
else
    maxPredictedSlack = max(validSlack);
end

qpMask = k >= p.id.Nid & k < p.simulation.K;
qpFlags = result.qpExitflag(qpMask);
qpFailures = sum(qpFlags <= 0 | isnan(qpFlags));

summary = table( ...
    result.D,result.q,rmse,mae,maxAbsError, ...
    mean(ssErrors),mean(abs(ssErrors)),totalVariation, ...
    maxStateViolation,maxInputViolation,maxPredictedSlack,qpFailures, ...
    'VariableNames',{'Degree','Coefficients','RMSE','MAE', ...
    'MaxAbsError','SteadyStateBias','SteadyStateAbsError', ...
    'TotalInputVariation','MaxStateViolation','MaxInputViolation', ...
    'MaxPredictedSlack','QPFailures'});
end
