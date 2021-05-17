function plot1SlotConstellation_Inner(Ant_freq,v_slot,len)
%% scatter 画星座图
if nargin==1
    v_slot=0;
    len=3276;
elseif nargin==2
    len=3276;
end
%% start figure
str=sprintf('Plot slot %d Constellation',v_slot);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
    subplot(5,4,i);
    hold on;
    %scatterplot(Ant_freq(:,i+v_slot*14));
    %scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
    cpx=Ant_freq(:,i);
    Id=real(cpx);
    Qd=imag(cpx);
    
    %scatter(Id,Qd);
    plot(Id(1:len),Qd(1:len),'.');
    str=sprintf('symbol:%d',i);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
    if i==3
        subplot(5,4,15);
        plot(Id(1:2:len),Qd(1:2:len),'.');
        str=sprintf('symbol:%d,dmrs 0',i);
        title(str);
        subplot(5,4,16);
        plot(Id(2:2:len),Qd(2:2:len),'.');
        str=sprintf('symbol:%d,dmrs 1',i);
        
        title(str);
        %phase=derotate(cpx);display(phase);
        %
    end
    if i==12
        subplot(5,4,17);
        plot(Id(1:2:len),Qd(1:2:len),'.');
        str=sprintf('symbol:%d,dmrs 0',i);
        title(str);
        subplot(5,4,18);
        plot(Id(2:2:len),Qd(2:2:len),'.');
        str=sprintf('symbol:%d,dmrs 1',i);
       title(str);
       %phase=derotate(cpx);
       %display(phase);
    end
end