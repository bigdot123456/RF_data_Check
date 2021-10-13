function plot1SlotConstellation_Inner(symbFreq,v_slot,len_view)
%% scatter 画星座图
if nargin==1
    v_slot=0;
    [len_fft,l_symb]=size(symbFreq);
    len_view=len_fft;
elseif nargin==2
    [len_fft,l_symb]=size(symbFreq);
    len_view=len_fft;
else
    [len_fft,l_symb]=size(symbFreq);
    %len_view=len_fft;
end
%% start figure
Scale=max(max(abs(symbFreq)));
if Scale==0
    Scale=1
end

slotSymbNum=14;
%len_fft=4096;
center_inx=len_fft/2;
pos1=  (center_inx-len_view/2+1):2:(center_inx+len_view/2);
pos2=1+(center_inx-len_view/2+1):2:(center_inx+len_view/2);

slot_num=ceil(l_symb/slotSymbNum);
for m=1:slot_num
    str=sprintf('Plot slot %d.%d Constellation with %d point',v_slot,m,len_view);
    figure('NumberTitle', 'on', 'Name', str);
    for i=1:slotSymbNum
        subplot(5,4,i);
        hold on;
        %scatterplot(Ant_freq(:,i+v_slot*14));
        %scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
        cpx=symbFreq(:,i+(m-1)*slotSymbNum);
        Id=real(cpx);
        Qd=imag(cpx);
        
        %scatter(Id,Qd);
        plot(Id(pos1),Qd(pos1),'.');
        plot(Id(pos2),Qd(pos2),'.r');
        str=sprintf('symbol:%d len:%d',i,len_view);
        title(str);
        axis([-Scale,Scale,-Scale,Scale]);
        %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
        grid on;
        if i==3
            subplot(5,4,15);
            plot(Id(pos1),Qd(pos1),'.');
            str=sprintf('symbol:%d,dmrs 0',i);
            title(str);
            %axis([-Scale,Scale,-Scale,Scale]);
            
            subplot(5,4,16);
            plot(Id(pos2),Qd(pos2),'.r');
            str=sprintf('symbol:%d,dmrs 1',i);
            title(str);
            %axis([-Scale,Scale,-Scale,Scale]);
            %phase=derotate(cpx);display(phase);
            %
        end
        if i==12
            subplot(5,4,17);
            plot(Id(pos1),Qd(pos1),'.g');
            str=sprintf('symbol:%d,dmrs 0',i);
            title(str);
            %axis([-Scale,Scale,-Scale,Scale]);
            
            subplot(5,4,18);
            plot(Id(pos2),Qd(pos2),'.m');
            str=sprintf('symbol:%d,dmrs 1',i);
            title(str);
            %axis([-Scale,Scale,-Scale,Scale]);
            %phase=derotate(cpx);
            %display(phase);
        end
    end
end