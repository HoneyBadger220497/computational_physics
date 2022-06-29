function u_np1 = laxFriedrichFDS(u_n, r, u_0, u_N)

U = [u_0, u_n, u_N];
u_np1 = (U(3:end) * (1-r) + U(1:end-2) * (1+r))/2;

end