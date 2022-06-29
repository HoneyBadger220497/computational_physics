function u_np1 = leapFrogFDS(u_n, u_nm1, r, u_0, u_N)

U = [u_0, u_n, u_N];
u_np1 = u_nm1 - r*(U(3:end) - U(1:end-2));

end