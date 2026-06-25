function [uNext,info] = solve_mpc_qp(x0,u0,A,B,c,rHorizon,p)
N = p.mpc.N;
M = N - 1;
assert(M >= 1,'The paper''s input indexing requires N >= 2.');

% Decision vector: [x_1,...,x_N,u_1,...,u_{N-1},eps_1,...,eps_N].
ix = 1:N;
iu = N + (1:M);
ie = N + M + (1:N);
nz = 3*N - 1;

Q = p.mpc.Q(:);
rHorizon = rHorizon(:);
H = zeros(nz,nz);
f = zeros(nz,1);

H(ix,ix) = diag(Q);
f(ix) = -Q.*rHorizon;

R = p.mpc.R;
H(iu(1),iu(1)) = H(iu(1),iu(1)) + R;
f(iu(1)) = f(iu(1)) - R*u0;
for i = 2:M
    H(iu(i),iu(i)) = H(iu(i),iu(i)) + R;
    H(iu(i-1),iu(i-1)) = H(iu(i-1),iu(i-1)) + R;
    H(iu(i),iu(i-1)) = H(iu(i),iu(i-1)) - R;
    H(iu(i-1),iu(i)) = H(iu(i-1),iu(i)) - R;
end

H(ie,ie) = p.mpc.S*eye(N);
H = 0.5*(H + H.');

Aeq = zeros(N,nz);
beq = zeros(N,1);
Aeq(1,ix(1)) = 1;
beq(1) = c + A*x0 + B*u0;
for i = 2:N
    Aeq(i,ix(i)) = 1;
    Aeq(i,ix(i-1)) = -A;
    Aeq(i,iu(i-1)) = -B;
    beq(i) = c;
end

% One scalar slack per stage is equivalent for the scalar interval |x| <= xMax.
Aineq = zeros(2*N,nz);
bineq = p.constraints.xMax*ones(2*N,1);
for i = 1:N
    Aineq(2*i-1,ix(i)) = 1;
    Aineq(2*i-1,ie(i)) = -1;
    Aineq(2*i,ix(i)) = -1;
    Aineq(2*i,ie(i)) = -1;
end

lb = -inf(nz,1);
ub = inf(nz,1);
lb(iu) = -p.constraints.uMax;
ub(iu) = p.constraints.uMax;
lb(ie) = 0;

persistent options
if isempty(options)
    options = optimoptions('quadprog','Display','off');
end

[z,fval,exitflag,output] = quadprog( ...
    H,f,Aineq,bineq,Aeq,beq,lb,ub,[],options);

if exitflag > 0 && ~isempty(z)
    uNext = z(iu(1));
    maxSlack = max(z(ie));
else
    uNext = min(max(u0,-p.constraints.uMax),p.constraints.uMax);
    maxSlack = NaN;
end

if isempty(fval)
    fval = NaN;
end

info.exitflag = exitflag;
info.objective = fval;
info.maxSlack = maxSlack;
if isstruct(output) && isfield(output,'iterations')
    info.iterations = output.iterations;
else
    info.iterations = NaN;
end
end
