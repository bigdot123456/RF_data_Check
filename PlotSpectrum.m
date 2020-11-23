%% read data from bin file
function log_freq=PlotSpectrum(IQ)
freq=abs(IQ);
base=max(freq);
pos=base==0;
base(pos)=1;
freq(:,pos)=1;
log_freq=10*log10(freq./base);
