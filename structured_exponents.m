function exponents = structured_exponents(D)
%STRUCTURED_EXPONENTS Forward-Euler-informed reduced scalar dictionary.
% Joint-odd symmetry is exact for the sampled flow. The additional omission
% of odd-total-degree terms such as x*u^2 is a deliberate model reduction
% motivated by the forward-Euler Taylor structure, not an exact RK4 claim.

assert(D >= 1 && mod(D,2) == 1, ...
    'The structured dictionary uses a positive odd Taylor degree.');

exponents = zeros(0,2);
for degree = 1:2:D
    exponents(end+1,:) = [degree 0]; %#ok<AGROW>
    for uPower = 1:2:degree
        exponents(end+1,:) = [degree-uPower uPower]; %#ok<AGROW>
    end
end
end
