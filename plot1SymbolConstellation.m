function log_freq=plot1SymbolConstellation(Ant_view,len)
%% plot slot frequency & constellation result
if nargin==1
    len=length(Ant_view);
end

%% spectrum
log_freq=20*log10(abs(Ant_view));

str=sprintf('1 symbol db frequency spectrum with %d point',len);
figure('NumberTitle', 'on', 'Name', str);
plot(log_freq,'.');
title(str);
grid on;

%% timing diagram
str=sprintf('1 symbol timing diagram with %d point',len);
figure('NumberTitle', 'on', 'Name', str);
plot(abs(Ant_view),'.');
title(str);
grid on;

%% constellation
Id=real(Ant_view);
Qd=imag(Ant_view);

%scatter(Id,Qd);
plot(Id(1:len),Qd(1:len),'.');
str=sprintf('OFDM symbol constellation');
title(str);
grid on;

