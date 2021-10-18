function [symbol_abs0,symbol_abs1]=plot1SlotFreqencySignalConstellation2Ant(SymbFreq_ant0,SymbFreq_ant1,slot_num)
%% plot 2 ant Spetrum & constellation
% [symbol_abs0,symbol_abs1]=plot1SlotFreqencySignalConstellation2Ant(SymbFreq_ant0,SymbFreq_ant1,slot_num)
% should input two ant Freq(1:4096,1:28) or likely data;
% slot_num is No.slot used to print message
% symbol_abs0: 20log(*) result
%
global Debug_view_Freq Debug_view3D Debug_view_constellation
if nargin==1
    slot_num=0;
    ant_num=1;
    SymbFreq_ant1=SymbFreq_ant0;
elseif nargin==2
    slot_num=0;
    ant_num=2;
else
    ant_num=2;
end

slotSymbNum=14;
len_fft=4096;

MIN=30;

format short;
%% start compare frequency domain analsys
symbol_abs0=20*log10(abs(SymbFreq_ant0));
symbol_abs0(symbol_abs0==-inf)=MIN;
symbol_abs1=20*log10(abs(SymbFreq_ant1));
symbol_abs1(symbol_abs1==-inf)=MIN;

t0=reshape(symbol_abs0,[],1);
t1=ones(length(t0),1);

t_max=max(t0);
t_min=min(t0);
if t_max==-inf
    t_max=0;
end
if t_min==-inf
    t_min=t_max-60;
end
t1=t_min.*t1;

for i=1:slotSymbNum
    t1(i*4096)=t_max+10;
end
%% plot works
if Debug_view3D
    str=sprintf('Ant%d slot %d continuous frequency signal with %d point',0,slot_num,length(SymbFreq_ant0));
    figure('NumberTitle', 'on', 'Name', str);
    mesh(abs(SymbFreq_ant0),'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in original scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-30);
    %plot(abs(Ant_view));
    title(str);
    grid on;
    colorbar;
    
    str=sprintf('Ant%d slot %d symbol IQ abs log power frequency series with %d point',0,slot_num,length(symbol_abs0(:,1)));
    figure('NumberTitle', 'on', 'Name', str);
    % plot(t0,'.r');hold on;
    % plot(t1,'b');
    mesh(symbol_abs0,'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in db scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-30);
    title(str);
    grid on;
    colorbar;
    
    if ant_num ==2
        str=sprintf('Ant%d slot %d continuous frequency signal with %d point',1,slot_num,length(SymbFreq_ant0));
        figure('NumberTitle', 'on', 'Name', str);
        mesh(abs(SymbFreq_ant1),'FaceAlpha','0.5');
        x1=xlabel('Symbol Direction: 1 -> 14');
        x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
        x3=zlabel('Sample value scale in original scale');
        set(x1,'Rotation',30);
        set(x2,'Rotation',-30);
        %plot(abs(Ant_view));
        title(str);
        grid on;
        colorbar;
        
        str=sprintf('Ant%d slot %d symbol IQ abs log power frequency series with %d point',1,slot_num,length(symbol_abs0(:,1)));
        figure('NumberTitle', 'on', 'Name', str);
        % plot(t0,'.r');hold on;
        % plot(t1,'b');
        mesh(symbol_abs1,'FaceAlpha','0.5');
        x1=xlabel('Symbol Direction: 1 -> 14');
        x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
        x3=zlabel('Sample value scale in db scale');
        set(x1,'Rotation',30);
        set(x2,'Rotation',-30);
        title(str);
        grid on;
        colorbar;
    end
end
%% plot every symbol spectrum
Scale=max(max(symbol_abs0));
if Scale==0
    Scale=1
end
fprintf('slot_num %d scale is %d',slot_num,Scale);
if Debug_view_Freq==1
    str=sprintf('Ant0 slot %d Freqency spectrum',slot_num);
    figure('NumberTitle', 'on', 'Name', str);
    subplot(3,5,15);
    plot(symbol_abs0,'.');
    str=sprintf('Ant0 s%d all symbol',slot_num);
    title(str);
    grid on;
    
    for i=1:slotSymbNum
        subplot(3,5,i);
        
        xy=symbol_abs0(:,i);
        len=length(xy);
        inx1=1:2:len;
        inx2=2:2:len;
        plot(inx1,xy(inx1),'.');
        hold on;
        plot(inx2,xy(inx2),'r.');
        
        symbol_max=max(symbol_abs0(:,i));
        symbol_ave=mean(symbol_abs0(:,i));
        
        symbol_fmax=max(abs(SymbFreq_ant0(:,i)));
        symbol_fave=mean(abs(SymbFreq_ant0(:,i)));
        para=20*log(symbol_fmax/symbol_fave);
        
        tstr=sprintf('s%d.%d,fmax:%d,fave:%d,par:%2.2f\t',slot_num,i-1,ceil(symbol_fmax),ceil(symbol_fave),para);
        fprintf(tstr);
        str=sprintf('s%d.%d,max:%2.2f,ave:%d,par:%2.2fdb\n',slot_num,i-1,symbol_max,ceil(symbol_ave),para);
        fprintf(str);
        title(str);
        %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
        grid on;
        axis([0,len_fft,Scale-60,Scale+3]);
    end
end

if Debug_view_Freq==1
    str=sprintf('Ant1 slot %d Freqency spectrum',slot_num);
    figure('NumberTitle', 'on', 'Name', str);
    subplot(3,5,15);
    plot(symbol_abs1,'.');
    str=sprintf('Ant1 s%d all symbol',slot_num);
    title(str);
    grid on;
    
    for i=1:slotSymbNum
        subplot(3,5,i);
        
        xy=symbol_abs1(:,i);
        len=length(xy);
        inx1=1:2:len;
        inx2=2:2:len;
        if i==3 || i==12
            plot(inx1,xy(inx1),'.');
            hold on;
            plot(inx2,xy(inx2),'r.');
        else
            plot(inx1,xy(inx1),'-g');
            hold on;
            plot(inx2,xy(inx2),'-m');
        end
        symbol_max=max(symbol_abs1(:,i));
        symbol_ave=mean(symbol_abs1(:,i));
        
        symbol_fmax=max(abs(SymbFreq_ant1(:,i)));
        symbol_fave=mean(abs(SymbFreq_ant1(:,i)));
        para=20*log(symbol_fmax/symbol_fave);
        
        tstr=sprintf('s%d.%d,fmax:%d,fave:%d,par:%2.2f\t',slot_num,i-1,ceil(symbol_fmax),ceil(symbol_fave),para);
        fprintf(tstr);
        str=sprintf('s%d.%d,max:%2.2f,ave:%d,par:%2.2fdb\n',slot_num,i-1,symbol_max,ceil(symbol_ave),para);
        fprintf(str);
        title(str);
        %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
        grid on;
       axis([0,len_fft,Scale-60,Scale+3]);
    end
end
%% start plot constellation
if Debug_view_constellation==1
    plot1SlotConstellation_Inner(SymbFreq_ant0(:,1:slotSymbNum),slot_num,512);
    plot1SlotConstellation_Inner(SymbFreq_ant1(:,1:slotSymbNum),slot_num,512);
end