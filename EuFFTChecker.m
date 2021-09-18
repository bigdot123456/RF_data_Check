%% load 1 symbol frequency data
close all;
clear;
load 'matlab1629.mat'

% enlarge the exp7
exp72_r=real(exp7)*2;
exp72_i=imag(exp7)*2;

exp72_r(exp72_r>32767)=32767;
exp72_r(exp72_r<-32767)=-32768;

exp72_i(exp72_i>32767)=32767;
exp72_i(exp72_i<-32767)=-32768;

exp72=exp72_r+1i*exp72_i;

exp7_abs=abs(exp7);
exp72_abs=abs(exp72)/2;

%% plot
figure();
plot(exp7_abs);
hold on;
plot(exp72_abs,'r');
grid on;
