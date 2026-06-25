function [phi,dphidx,dphidu] = taylor_features(x,u,exponents)
xPower = exponents(:,1);
uPower = exponents(:,2);

phi = x.^xPower .* u.^uPower;

dphidx = zeros(size(phi));
idx = xPower > 0;
dphidx(idx) = xPower(idx).*x.^(xPower(idx)-1).*u.^uPower(idx);

dphidu = zeros(size(phi));
idx = uPower > 0;
dphidu(idx) = uPower(idx).*x.^xPower(idx).*u.^(uPower(idx)-1);
end
