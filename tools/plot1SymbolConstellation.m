function log_freq=plot1SymbolConstellation(Ant_view,t_or_f,len,fig_str,ViewAll)
%% plot slot frequency & constellation result
% log_freq=plot1SymbolConstellation(Ant_view,t_or_f,len,fig_str,ViewAll)
% t_or_f:input data is frequency or timing signal,default is t
len_fft=4096;
if nargin==0
    sn=1:len_fft;
    Ant_view=sinc(sn/4096)+1i*exp(1i-sn/2047);
end

if nargin<2
    t_or_f=1;
end

if nargin<3
    len= min(len_fft,length(Ant_view));
end

if nargin<4
    fig_str="Timing signal Input ";
end

if nargin<5
    ViewAll=1;
end

if t_or_f==1
    View0=floor((len_fft-len)/2);
    viewSN=1:2:len;
    viewSN1=View0+viewSN;
    viewSN2=View0+viewSN+1;
else
    viewSN1=1:2:len;
    viewSN2=2:2:len;
end

pos1=1:2:len;
pos2=2:2:len;
%% spectrum
if t_or_f==1
    l=length(Ant_view);
    if l<len_fft
        x=[Ant_view ; zeros(len_fft-l,1)];
    else
        x=Ant_view(1:len_fft);
    end
    AntFreq=fftshift(fft(x));
else
    AntFreq=Ant_view;
end
%% log data;

log_freq=20*log10(abs(AntFreq));

str=sprintf('%s:1 symbol frequency spectrum DB scaled with %d point',fig_str,len);
figure('NumberTitle', 'on', 'Name', str);
if ViewAll==1
    subplot(2,2,1);
end

plot(pos1,log_freq(pos1),'-');
hold;
plot(pos2,log_freq(pos2),'-r');
str=sprintf('timing log diagram with %d point',len);
title(str);
grid on;

%% timing diagram
Scale=max(abs(AntFreq(:)));
if Scale==0
    Scale=1;
end

str=sprintf('%s:1 symbol timing diagram with %d point',fig_str,len);
if ViewAll==1
    subplot(2,2,2);
else
    figure('NumberTitle', 'on', 'Name', str);
    subplot(2,1,1);
end
plot(viewSN1,abs(AntFreq(viewSN1)),'.b');
hold;
plot(viewSN2,abs(AntFreq(viewSN2)),'.r');
str=sprintf('Origin ABS Data');
title(str);
grid on;

if ViewAll==1
    subplot(2,2,4);
else
    figure('NumberTitle', 'on', 'Name', str);
    subplot(2,1,2);
end
plot(viewSN1,angle(AntFreq(viewSN1)),'.b');
hold;
plot(viewSN2,angle(AntFreq(viewSN2)),'.r');
str=sprintf('angle Data');
title(str);
grid on;

%% constellation
str=sprintf('%s:1 symbol Constellation diagram with %d point',fig_str,len);
if ViewAll==1
    subplot(2,2,3);
else
    figure('NumberTitle', 'on', 'Name', str);
end

Id=real(AntFreq);
Qd=imag(AntFreq);

%scatter(Id,Qd);


plot(Id(viewSN1),Qd(viewSN1),'.');
hold;
plot(Id(viewSN2),Qd(viewSN2),'.m');

str=sprintf('%s:OFDM symbol constellation, max:%d',fig_str,ceil(Scale));
title(str);
grid on;
axis([-Scale,Scale,-Scale,Scale]);

