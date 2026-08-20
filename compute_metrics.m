function [summary,segments] = compute_metrics(result,p)
%COMPUTE_METRICS Compute the documented canonical evaluation metrics.
% Overall RMSE/MAE use k >= Nid, including the final state sample at K.
% Segment metrics use each 300-sample half-open interval [start,stop).
% For amplitude-swept sine segments, evaluated error discards one complete
% sinusoidal period (200 samples for the canonical experiment).

k = result.k;
e = result.x - result.reference;
controlMask = k >= p.id.Nid;

rmse = sqrt(mean(e(controlMask).^2));
mae = mean(abs(e(controlMask)));
maxAbsError = max(abs(e(controlMask)));

segmentRows = cell(numel(get_reference_levels(p)),1);
ssErrors = zeros(0,1);

levels = get_reference_levels(p);
segmentStart = p.id.Nid + (0:numel(levels)-1)*p.reference.Kr;
segmentStop = segmentStart + p.reference.Kr;

for j = 1:numel(segmentStart)
    mask = k >= segmentStart(j) & k < segmentStop(j);

    segmentError = e(mask);
    segmentInput = result.u(mask);
    segmentState = result.x(mask);

    if isfield(p.reference,'type') && strcmpi(p.reference.type,'amp_sine')
        skip = round(1/(p.reference.frequencyHz*p.plant.Ts));
        evalStart = min(segmentStart(j) + skip, segmentStop(j)-1);
    else
        evalStart = max(segmentStart(j),segmentStop(j)-p.metrics.ssWindow);
    end

    evalMask = k >= evalStart & k < segmentStop(j);
    evalError = e(evalMask);
    ssErrors = [ssErrors; evalError(:)]; %#ok<AGROW>

    if numel(segmentInput) > 1
        segmentTV = sum(abs(diff(segmentInput)));
    else
        segmentTV = 0;
    end

    satRatioU = mean(abs(segmentInput) > 0.98*p.constraints.uMax);
    satRatioX = mean(abs(segmentState) > 0.98*p.constraints.xMax);

    segmentRows{j} = table( ...
        result.D,levels(j), ...
        sqrt(mean(segmentError.^2)), ...
        mean(abs(segmentError)), ...
        max(abs(segmentError)), ...
        mean(evalError), ...
        mean(abs(evalError)), ...
        segmentTV, ...
        satRatioU, ...
        satRatioX, ...
        'VariableNames',{'Degree','ReferenceLevel','RMSE', ...
        'MAE','MaxAbsError','BiasEval','AbsErrorEval', ...
        'InputVariation','InputSaturationRatio','StateSaturationRatio'});
end

segments = vertcat(segmentRows{:});

controlInput = result.u(controlMask);
if numel(controlInput) > 1
    totalVariation = sum(abs(diff(controlInput)));
else
    totalVariation = 0;
end

% Violations are measured over all stored samples, including initialization.
maxStateViolation = max([0; abs(result.x(:))-p.constraints.xMax]);
maxInputViolation = max([0; abs(result.u(:))-p.constraints.uMax]);

% Slack is the largest optimized soft-state-constraint relaxation.
validSlack = result.qpMaxSlack(~isnan(result.qpMaxSlack));
if isempty(validSlack)
    maxPredictedSlack = NaN;
else
    maxPredictedSlack = max(validSlack);
end

% One QP is solved for each control instant Nid,...,K-1.
qpMask = k >= p.id.Nid & k < p.simulation.K;
qpFlags = result.qpExitflag(qpMask);
qpFailures = sum(qpFlags <= 0 | isnan(qpFlags));

summary = table( ...
    result.D,result.q,rmse,mae,maxAbsError, ...
    mean(ssErrors),mean(abs(ssErrors)),totalVariation, ...
    maxStateViolation,maxInputViolation,maxPredictedSlack,qpFailures, ...
    'VariableNames',{'Degree','Coefficients','RMSE','MAE', ...
    'MaxAbsError','BiasEval','AbsErrorEval', ...
    'TotalInputVariation','MaxStateViolation','MaxInputViolation', ...
    'MaxPredictedSlack','QPFailures'});
end


function levels = get_reference_levels(p)

if isfield(p.reference,'type') && strcmpi(p.reference.type,'amp_sine')
    levels = p.reference.ampLevels(:);
else
    levels = p.reference.commands(:);
end

end
