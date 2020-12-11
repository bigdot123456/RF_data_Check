function tab = phy_gnb_main_init_phase_compensation_table( f0,  mu, conjugate)
%% total 28 symbol table out.
% mu should be 1;
% conjugate should be 1
% f0 is set to 26550000 Hz
NUM_OF_SYMBOL_PER_SLOT = 14;
k = 64.;
delta_f_max = 480000.;
N_f = 4096.;
Tc = 1. / (delta_f_max*N_f);
coef1 = 2^mu;
coef2 = 2^(-mu);
N_u = 2048. * k * coef2;
L = NUM_OF_SYMBOL_PER_SLOT * coef1;
%      sign = -1;
ncp = 144;
ncp0 = 16;
N_CP = zeros(1,NUM_OF_SYMBOL_PER_SLOT * 10 * 2);
t = zeros(1,NUM_OF_SYMBOL_PER_SLOT * 10 * 2);
t2 = zeros(1,NUM_OF_SYMBOL_PER_SLOT * 10 * 2);

for m = 1:L
    
    if (m == 1 || m == (L/2+1))
        
        N_CP(m) = ncp * k * coef2 + ncp0 * k;
        
    else
        
        N_CP(m) = ncp * k * coef2;
    end
    t(m) = 0;
    for  l_p = 1: m-1
        t(m) = t(m) + N_CP(l_p);
    end
    t2(m) = (m-1) * N_u + t(m) + N_CP(m);
end

sign = 1.;
if 1== conjugate
    
    sign = -1.;
end
M_PI = pi;
for m = 1:L
    tab(m) = exp(1i*2*pi*f0* t2(m) * Tc);
end

return;
