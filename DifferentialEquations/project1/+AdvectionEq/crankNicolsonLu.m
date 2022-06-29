function  u_np1 = crankNicolsonLu(u_n, r, L, U)

uj = u_n;
ujp1 = [u_n(2:end),u_n(1)];
ujm1 = [u_n(end), u_n(1:end-1)];
h = r*(ujm1 - ujp1) + 4*uj;

%%% solve linear system of equation A*u_np1 = h
n = length(u_n);
% forward substitution to solve U*v = h^1
v = zeros(1,n);
v(1) = h(1);
for idx = 2:1:n
    v(idx) = h(idx)- L(idx,1:idx-1)*v(1:idx-1).';
end

% backward substitution to solve L*u_np1 = v
u_np1 = zeros(1,n);
u_np1(end) = v(end)/U(end,end);
for idx = n-1:-1:1
    u_np1(idx) = (v(idx) - U(idx,idx+1:end)*u_np1(idx+1:end).')/U(idx,idx);
end

end