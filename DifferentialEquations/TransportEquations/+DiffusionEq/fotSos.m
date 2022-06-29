function [u_np1] = fotSos(u_n, s, u_0, u_N)

U = [u_0,u_n,u_N];
u_np1 = (1-2*s)*U(2:end-1) + s*U(1:end-2) + s*U(3:end);

end

