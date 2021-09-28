function log_freq=plot1SymbolConstellation(Ant_view,len,fig_str)
%% plot slot frequency & constellation result
if nargin==0
    sn=1:4096;
    Ant_view=sinc(sn/4096)+1i*exp(1i-sn/2047);    
    len=length(Ant_view);
    fig_str="Demo";
elseif nargin==1
    len=length(Ant_view);
    fig_str="BBData";
elseif nargin==2
    fig_str="BBData";
end

%% spectrum
log_freq=20*log10(abs(Ant_view));

str=sprintf('%s:1 symbol frequency spectrum DB scaled with %d point',fig_str,len);
figure('NumberTitle', 'on', 'Name', str);
pos1=1:2:len;
pos2=2:2:len;
plot(pos1,log_freq(pos1),'.');
hold;
plot(pos2,log_freq(pos2),'.m');
title(str);
grid on;

%% timing diagram
str=sprintf('%s:1 symbol timing diagram with %d point',fig_str,len);
figure('NumberTitle', 'on', 'Name', str);
plot(abs(Ant_view),'.');
title(str);
grid on;

%% constellation
Id=real(Ant_view);
Qd=imag(Ant_view);
Scale=max(abs(Ant_view(:)));

%scatter(Id,Qd);
plot(Id(1:2:len),Qd(1:2:len),'.');
hold;
plot(Id(2:2:len),Qd(2:2:len),'.m');

str=sprintf('%s:OFDM symbol constellation, max:%d',fig_str,ceil(Scale));
title(str);
grid on;
axis([-Scale,Scale,-Scale,Scale]);

