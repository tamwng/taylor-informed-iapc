function r = reference_signal(k,p)
inputSize = size(k);
k = k(:);
r = zeros(size(k));

if ~isfield(p.reference,'type')
    p.reference.type = 'steps';
end

switch lower(p.reference.type)

    case 'steps'
        r = reference_steps(k,p);

    case 'sine'
        r = reference_sine(k,p);

    case 'amp_sine'
        r = reference_amplitude_sine(k,p);

    case 'multisine'
        r = reference_multisine(k,p);

    otherwise
        error('Unknown reference type: %s',p.reference.type);
end

r = reshape(r,inputSize);
end


function r = reference_steps(k,p)
Nid = p.id.Nid;
Kr = p.reference.Kr;
commands = p.reference.commands;

r = zeros(size(k));

for j = 1:numel(commands)
    startIndex = Nid + (j-1)*Kr;
    stopIndex = startIndex + Kr;
    mask = k >= startIndex & k < stopIndex;
    r(mask) = commands(j);
end
end


function r = reference_sine(k,p)
r = zeros(size(k));

mask = k >= p.id.Nid;
tau = (k(mask) - p.id.Nid)*p.plant.Ts;

A = p.reference.amplitude;
f = p.reference.frequencyHz;
bias = getfield_with_default(p.reference,'bias',0);
phase = getfield_with_default(p.reference,'phase',0);

r(mask) = bias + A*sin(2*pi*f*tau + phase);
end


function r = reference_amplitude_sine(k,p)
r = zeros(size(k));

mask = k >= p.id.Nid;
kc = k(mask) - p.id.Nid;
tau = kc*p.plant.Ts;

f = p.reference.frequencyHz;
bias = getfield_with_default(p.reference,'bias',0);
phase = getfield_with_default(p.reference,'phase',0);

ampLevels = p.reference.ampLevels(:);
segment = floor(kc/p.reference.Kr) + 1;
segment = min(segment,numel(ampLevels));

A = ampLevels(segment);
r(mask) = bias + A.*sin(2*pi*f*tau + phase);
end


function r = reference_multisine(k,p)
r = zeros(size(k));

mask = k >= p.id.Nid;
tau = (k(mask) - p.id.Nid)*p.plant.Ts;

A = p.reference.amplitudes(:);
f = p.reference.frequenciesHz(:);

if isfield(p.reference,'phases')
    phase = p.reference.phases(:);
else
    phase = zeros(size(A));
end

bias = getfield_with_default(p.reference,'bias',0);
rr = bias*ones(size(tau));

for i = 1:numel(A)
    rr = rr + A(i)*sin(2*pi*f(i)*tau + phase(i));
end

r(mask) = rr;
end


function value = getfield_with_default(s,fieldName,defaultValue)
if isfield(s,fieldName)
    value = s.(fieldName);
else
    value = defaultValue;
end
end
