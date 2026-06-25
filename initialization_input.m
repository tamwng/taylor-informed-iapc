function u = initialization_input(k,p)
levels = p.id.levels;
u = levels(mod(k,numel(levels)) + 1);
end
