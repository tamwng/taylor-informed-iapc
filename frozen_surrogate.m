function [A,B,c,fhat] = frozen_surrogate(theta,exponents,x,u)
[phi,dphidx,dphidu] = taylor_features(x,u,exponents);

fhat = theta.'*phi;
A = theta.'*dphidx;
B = theta.'*dphidu;
c = fhat - A*x - B*u;
end
