function [theta,P,error,yhat] = rls_update(theta,P,phi,y,lambda)
yhat = theta.'*phi;
error = y - yhat;

L = P/lambda;
v = L*phi;
P = L - (v*v.')/(1 + phi.'*v);
P = 0.5*(P + P.');
theta = theta + P*phi*error;
end
