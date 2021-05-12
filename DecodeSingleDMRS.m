function [cpx_pc,d_ang_min_norm]=DecodeSingleDMRS(cpx)
%% this function is decode dmrs
len=length(cpx);
std_threshold=pi/8;
MAX_D=16;
d_cpx=-1*ones(len,MAX_D);
ang=angle(cpx);
for i=1:MAX_D
    d_cpx(1+i:end,i)=cpx(1+i:end).*conj(cpx(1:end-i));
end
%% get diff phase
d_ang=angle(d_cpx);
for i=1:MAX_D
    d_cpx(1+i:end,i)=cpx(1+i:end).*conj(cpx(1:end-i));
end
%% use threshold to get rid of abnormal data
[d_ang_min,I]=min(abs(d_ang),[],2);
pos=d_ang_min>std_threshold;
d_ang_min(pos)=0;

%% use standard average to get phase error
d_ang_min_norm=d_ang_min./I;
fc=sum(d_ang_min_norm)/(length(d_ang_min_norm)-sum(pos));

%% phase correction
pc=exp(1i*-fc*(0:len-1));
cpx_pc=cpx.*pc';
ang_pc=angle(cpx_pc);
%% plot all debug info
figure;plot(ang,'.');
hold on;
plot(ang_pc,'*');
title("orignal angle plot");grid on;

figure;plot(ang_pc,'.');
title("phase correct angle plot");grid on;

figure;plot(d_ang_min,'.');
title("mini diff angle plot");grid on;

figure;plot(d_ang_min_norm,'.');
title("normal diff angle plot");grid on;

figure;plot(d_ang_min_norm,'.');
title("normal diff angle plot");grid on;
end