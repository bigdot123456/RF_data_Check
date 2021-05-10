function Ant_freq=plotDMRS(Ant_view,v_slot,len)
%% plot slot DMRS symbol
if nargin==1
    v_slot=0;
    len=length(Ant_view(:,1));
elseif nargin==2
    len=length(Ant_view(:,1));
end

Ant_freq=PlotSpectrum(Ant_view);
%% frequency figure demo
str=sprintf('Plot slot %d freq',v_slot);
figure('NumberTitle', 'on', 'Name', str);
%figure('NumberTitle', 'off', 'Name', str);
subplot(2,2,1);
plot(Ant_freq(1:2:end,3+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant0 symbol 3');
title(str);

subplot(2,2,2);
plot(Ant_freq(2:2:end,3+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant1 symbol 3');
title(str);

subplot(2,2,3);
plot(Ant_freq(1:2:end,12+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant0 symbol 12');
title(str);

subplot(2,2,4);
plot(Ant_freq(2:2:end,12+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant1 symbol12');
title(str);


%% second symbol
i=3;
cpx=Ant_view(:,i+v_slot*14);
Id=real(cpx);
Qd=imag(cpx);
cpx00=abs(Id)+1j*abs(Qd);
p0_ang=angle(cpx00);
%% plot constellation & angle phase
constellationstr=sprintf('Plot slot %d dmrs %d constellation',v_slot,i);
anglestr=sprintf('Plot slot %d dmrs %d angle',v_slot,i);

figure('NumberTitle', 'on', 'Name', str);
subplot(2,1,1);
plot(Id(1:2:len),Qd(1:2:len),'.');
title(constellationstr);
subplot(2,1,2);
plot(Id(2:2:len),Qd(2:2:len),'.');
title(constellationstr);

figure
subplot(2,1,1);
plot(p0_ang(1:2:len),'.');
title(anglestr);
subplot(2,1,2);
plot(p0_ang(2:2:len),'.');
title(anglestr);
%phase=derotate(cpx);display(phase);

%% second symbol
i=12;
cpx=Ant_view(:,i+v_slot*14);
Id=real(cpx);
Qd=imag(cpx);
cpx00=abs(Id)+1j*abs(Qd);
p0_ang=angle(cpx00);
%% plot constellation & angle phase
constellationstr=sprintf('Plot slot %d dmrs %d constellation',v_slot,i);
anglestr=sprintf('Plot slot %d dmrs %d angle',v_slot,i);

figure('NumberTitle', 'on', 'Name', str);
subplot(2,1,1);
plot(Id(1:2:len),Qd(1:2:len),'.');
title(constellationstr);
subplot(2,1,2);
plot(Id(2:2:len),Qd(2:2:len),'.');
title(constellationstr);

figure
subplot(2,1,1);
plot(p0_ang(1:2:len),'.');
title(anglestr);
subplot(2,1,2);
plot(p0_ang(2:2:len),'.');
title(anglestr);
%phase=derotate(cpx);display(phase);
end

