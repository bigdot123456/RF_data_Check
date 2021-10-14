function iq_freq1=plotLTE(iq)
%% plot data
iq_abs=abs(iq);
figure;
plot(iq_abs,'.');
str=sprintf("LTE timing view");
title(str);
grid on;

%% constellation
str=sprintf("LTE constellation");
figure;
iq_freq=ifft(iq);
scatter(real(iq_freq),imag(iq_freq));
title(str);
grid on;
%% spectrum
iq_freq1=fftshift(iq_freq);
iq_freq_abs=abs(iq_freq1);
iq_spectrum=20*log(iq_freq_abs);

str=sprintf("LTE spetrum");
figure;
plot(iq_spectrum);
title(str);
grid on;
end