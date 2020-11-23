%% random test for wrtieAnt
testfile='good.bin';
a=rand(1,3276*14);
a_fft=fft(a);
a0=ifft(a_fft);
a_iq(:,1)=real(a_fft);
a_iq(:,2)=imag(a_fft);
a_iq1=reshape(a_iq',1,length(a_iq)*2)';
data=writeAnt(testfile,a_iq1);
data1=readAnt(testfile);
data2=reshape(data1',1,length(a_iq))';
pos=real(data2)==(2^15-1);
data2(pos)=2^15+1i*imag(data2(pos));
data3=ifft(data2);

disp('ok!',length(data1));