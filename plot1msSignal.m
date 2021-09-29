function slotCollectFreq=plot1msSignal(Ant_view,ant_num)
if nargin==1
    ant_num=0;
end
MIN=+30;

ms_5TsNum=61440;
len_fft=4096;
symNum=14;
slotNum=floor(length(Ant_view)/ms_5TsNum);
slotCollect=reshape(Ant_view(1:slotNum*ms_5TsNum),ms_5TsNum,[]);
slotCollectFreq=zeros(len_fft,slotNum*symNum);
slotCollectTime=zeros(len_fft,slotNum*symNum);

for m=1:slotNum
    slotFFTIn=splitSlot2Symbol(slotCollect(:,m));
    slotCollectTime(:,(m-1)*symNum+1:m*symNum)=slotFFTIn;
    for n=1:symNum
        slotFFTout=fft(slotFFTIn(:,n));
        slotFFTout1=fftshift(slotFFTout);
        slotCollectFreq(:,(m-1)*symNum+n)=slotFFTout1;
    end
end

%% start Timing &Freqency domain analsys
symbol_tabs=20*log10(abs(slotCollectTime));
symbol_tabs(symbol_tabs==-inf)=MIN;
symbol_fabs=20*log10(abs(slotCollectFreq));
symbol_fabs(symbol_fabs==-inf)=MIN;
%% plot t signal with 3D view
str=sprintf('Ant%d continuous Timing signal with %d point',ant_num,length(Ant_view));
figure('NumberTitle', 'on', 'Name', str);
s=mesh(symbol_tabs,'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample timing Direction: 1 -> 4096');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
colorbar;
%s.FaceColor = 'flat';
grid on;
%% plot f signal with 3D view
str=sprintf('Ant%d continuous freqency signal with %d slot',ant_num,slotNum);
figure('NumberTitle', 'on', 'Name', str);
s=mesh(symbol_fabs,'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample subcarrier Direction: 1 -> 4096');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
colorbar;
%s.FaceColor = 'flat';
grid on;
end