function [slotCollectFreq,slotUpCollectFreq]=Process1msSignal(Ant_view,viewNum,ant_num)
%% process 1ms signal with STO & CFO
% [slotCollectFreq,slotUp]=Process1msSignal(Ant_view,viewNum,ant_num)
% ant_num is used to figure view
global Debug_view Ant_debug Debug_slotSTO_CFO Debug_slotSTO_CFO_More
%global Debug_slotSTO_CFO;
%global Debug_sto;

if nargin==0
    ant_num=0;
    viewNum=400;
    load './Ant_view.mat'
elseif nargin==1
    viewNum=400;
    ant_num=0;
elseif nargin==2
    ant_num=0;
end

if Ant_debug==1
    save 'Ant_view.mat'
end


%% basic parameter
MIN=+30;

ms_5TsNum=61440;
len_fft=4096;
symNum=14;
slotNum=floor(length(Ant_view)/ms_5TsNum);
slotCollect=reshape(Ant_view(1:slotNum*ms_5TsNum),ms_5TsNum,[]);
slotCollectFreq=zeros(len_fft,slotNum*symNum);
slotCollectTime=zeros(len_fft,slotNum*symNum);
upcnt=1;
slotUpCollectTime=zeros(len_fft,ceil(slotNum/10*2)*symNum);
slotUpCollectFreq=zeros(len_fft,ceil(slotNum/10*2)*symNum);

viewSlotNum=min(slotNum,viewNum);
for m=1:viewSlotNum
    slotFFTIn=splitSlot2Symbol(slotCollect(:,m));
    
    slotCollectTime(:,(m-1)*symNum+1:m*symNum)=slotFFTIn;
    for n=1:symNum
        slotFFTout=fft(slotFFTIn(:,n));
        slotFFTout1=fftshift(slotFFTout);
        slotCollectFreq(:,(m-1)*symNum+n)=slotFFTout1;
    end
    
    m1=mod(m,20);
    if m1==10 || m1==9 ||m1==0 || m1==19
        posUp=(upcnt-1)*symNum+1:upcnt*symNum;
        
        if m==slotNum
            %  [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(SlotIn,lastSlotIn,nextSlotIn,OFDMParam)
            [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(slotCollect(:,m),slotCollect(:,m-1));
        else
            [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(slotCollect(:,m),slotCollect(:,m-1),slotCollect(:,m+1));
        end
        slotUpCollectTime(:,posUp)=SymbolOutWithEQ;
        for n=1:symNum
            slotFFTout=fft(SymbolOutWithEQ(:,n));
            slotFFTout1=fftshift(slotFFTout);
            slotUpCollectFreq(:,(upcnt-1)*symNum+n)=slotFFTout1;
        end
        upcnt=upcnt+1;
        
    end
    
end

if Debug_view==1
    %% start Timing &Freqency domain analsys
    symbol_tabs=20*log10(abs(slotCollectTime));
    symbol_tabs(symbol_tabs==-inf)=MIN;
    symbol_fabs=20*log10(abs(slotCollectFreq));
    symbol_fabs(symbol_fabs==-inf)=MIN;
    symbol_utabs=20*log10(abs(slotUpCollectTime));
    symbol_utabs(symbol_utabs==-inf)=MIN;
    symbol_ufabs=20*log10(abs(slotUpCollectFreq));
    symbol_ufabs(symbol_ufabs==-inf)=MIN;
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
    %% plot ut signal with 3D view
    str=sprintf('Ant%d STO&FC Timing signal with %d point',ant_num,length(symbol_utabs));
    figure('NumberTitle', 'on', 'Name', str);
    s=mesh(symbol_utabs,'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample timing Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in original scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-45);
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
    %% plot uf signal with 3D view
    str=sprintf('Ant%d STO&CFO freqency signal with %d slot',ant_num,length(symbol_ufabs));
    figure('NumberTitle', 'on', 'Name', str);
    s=mesh(symbol_ufabs,'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in original scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-45);
    %plot(abs(Ant_view));
    title(str);
    colorbar;
    %s.FaceColor = 'flat';
    grid on;
end

end