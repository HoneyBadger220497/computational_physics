function u_np1 = downwindFDS(u, r, u_0)

U = [u_0, u];
u_np1 = U(2:end) - r*(U(2:end) - U(1:end-1));

end