function view_range=PlotSeqSpectrum(log_freq,seppoint)
sc_len=3276;
view_min=-70;
view_range=seppoint(1)*sc_len+1:seppoint(2)*sc_len;
zeros_limit=view_min*ones(length(view_range),1);
zeros_limit(1:3276:length(zeros_limit))=0;
figure;
plot(log_freq(view_range));
hold on;
plot(zeros_limit,'r');
grid on;
str=sprintf('partial continuous OFDM symbol spectrum');
title(str);