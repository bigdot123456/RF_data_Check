%% plot frequency spectrum
close all;
load caps.mat

%%
plot(20*log10(abs(fd_35)));
grid on;
title('FPGA freqency Data,6-agc does not work');