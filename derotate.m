function [phase]=derotate(Ant_view)
%% blind frequency offset detection
angle_max=pi/3;
ant_port0=Ant_view(1:2:end);
ant_port1=Ant_view(2:2:end);

ant_port0_IQ=abs(real(ant_port0))+1i*abs(imag(ant_port0));
ant_port1_IQ=abs(real(ant_port1))+1i*abs(imag(ant_port1));
%% debug original phase;
figure;
p0_ang=angle(ant_port0);
p1_ang=angle(ant_port1);
plot(p0_ang,'.');
hold on;grid on;
plot(p1_ang,'r.');
title('orginal phase view');

ant_port0_IQ_diff=ant_port0_IQ(1:end-1).*ant_port0_IQ(2:end);
ant_port1_IQ_diff=ant_port1_IQ(1:end-1).*ant_port1_IQ(2:end);

ant_port0_IQ_diff_angle=angle(ant_port0_IQ_diff);
ant_port1_IQ_diff_angle=angle(ant_port1_IQ_diff);
%% plot diff phase
index0=abs(ant_port0_IQ_diff_angle)< angle_max;
index1=abs(ant_port1_IQ_diff_angle)< angle_max;
figure;
plot(ant_port0_IQ_diff_angle,'.');
hold on;
plot(ant_port1_IQ_diff_angle,'r.');
grid on;
title('diff phase view');
figure;

%%
phase_ok0=ant_port0_IQ_diff_angle(index0);
phase_ok1=ant_port0_IQ_diff_angle(index1);

phase(1)=mean(phase_ok0);
phase(2)=mean(phase_ok1);
end