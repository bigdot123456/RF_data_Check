function fft_rb=plotSlotConstellation(ant_slot,v_slot)
%% plot slot with time-domain data
if nargin==1
    v_slot=0;
elseif nargin==0
    fprintf("Should input ant data\n");
    return
end

%% const
len_slot=14;
len_scp=288;
len_lcp=352;
fft_len=4096;
prb_len=3276;

view_range=1:prb_len;
%view_range=240:440;

len_sym=(fft_len+len_scp);%%
sp=zeros(len_slot,1);

fft_in=zeros(fft_len,len_slot);
fft_out=fft_in;

%% start fft
sp(1)=len_lcp/2;
fft_in(:,1)=ant_slot(sp(1):sp(1)+fft_len-1);
for i=2:len_slot
    sp(i)=len_lcp+fft_len+len_sym*(i-2)+len_scp/2;
    fft_in(:,i)=ant_slot(sp(i):sp(i)+fft_len-1);
end

for i=1:len_slot
    fft_out(:,i)=fft(fft_in(:,i),fft_len);
end

fft_shift=zeros(fft_len,len_slot);
fft_shift(1:fft_len/2,:)=fft_out(fft_len/2+1:end,:);
fft_shift(fft_len/2+1:end,:)=fft_out(1:fft_len/2,:);

sp=(fft_len-prb_len)/2+1;

fft_rb=fft_shift(sp:sp+prb_len-1,:);

%% frequency figure demo
str=sprintf('Plot slot %d freq',v_slot);
figure('NumberTitle', 'on', 'Name', str);
%figure('NumberTitle', 'off', 'Name', str);
fft_rb_abs=abs(fft_rb);
fft_rb_abs_max=max(fft_rb_abs(1:end));
log_freq=zeros(prb_len,len_slot);

for i=1:14
    subplot(5,3,i);
    log_freq(:,i)=20*log10(fft_rb_abs(:,i)./fft_rb_abs_max);
    str=sprintf('OFDM symbol:%d',i-1);
    plot(log_freq(:,i));
    title(str);
    hold on;
    grid on;
end

%% scatter 画星座图
raster_freq=2.5880e9;
PhaseComp=phy_gnb_main_init_phase_compensation_table(raster_freq,1,1);
fft_rb_pc=fft_rb.*PhaseComp(1:14);
str=sprintf('Plot slot %d Constellation',v_slot);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
    subplot(5,3,i);
    hold on;
    %scatterplot(Ant0_freq(:,i+v_slot*14));
    %scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
    
    Id=real(fft_rb_pc(:,i));
    Qd=imag(fft_rb_pc(:,i));
    %scatter(Id,Qd);
    plot(Id(view_range),Qd(view_range),'.');
    str=sprintf('OFDM symbol:%d',i-1);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
end


