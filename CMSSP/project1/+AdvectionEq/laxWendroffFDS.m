function u_np1 = laxWendroffFDS(u_n, r, u_0, u_N)

U = [u_0, u_n, u_N];
u_np1 = U(2:end-1) * (1-r^2) - ...
        U(3:end)   * r * (r-1)/2 + ...
        U(1:end-2) * r * (r+1)/2;

end