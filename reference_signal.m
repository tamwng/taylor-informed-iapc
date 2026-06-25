function r = reference_signal(k,p)
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
