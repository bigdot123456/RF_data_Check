clear all;  
  close all;
  clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% catch_symb_num=280;
% SYMB0_LEN=3276;
% SYMBX_LEN=3276;
% SYMBDDR_LEN =4464;
% % SLOT_LEN =61440*4;
% SLOT_SYMB_NUM=14;
% ANT_NUM =4;
% SLOT_NUM = catch_symb_num/SLOT_SYMB_NUM;
% SlotSymNum = (SYMB0_LEN+SYMBX_LEN*13);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% filename = 'EU_DDR_DATA\ddr_dat_mcs20_1dmrs.txt';
% filename = 'EU_DDR_DATA\ddr_dat_mcs20_2dmrs.txt';
 filename = 'excel\iladata_snr15_f53.txt';

a=textread(filename,'%s');

b = char([]);

for i=1:length(a)
       b(i,:)=a{i};
end
%  b1=reshape(b,4,[]).';

u16_b = hex2dec(reshape(b,4,[]).');
s16_b = (u16_b >=32768 ).*(u16_b-2^16)+(u16_b < 32768 ).*(u16_b);

c_b = s16_b(2:2:end) + s16_b(1:2:end)*sqrt(-1);
AntData = zeros(SlotSymNum*SLOT_NUM,ANT_NUM);
for i=1:SLOT_NUM
   for j=1:SLOT_SYMB_NUM
        for k=1:ANT_NUM
             start_pos = SlotSymNum*(i-1)+ SYMBX_LEN*(j-1) + (j>1)*(SYMB0_LEN-SYMBX_LEN);
             if j == 1
                len = SYMB0_LEN;
             else
                len = SYMBX_LEN;
             end
             AntData(start_pos+(1:len),k) = c_b((i-1)*ANT_NUM*SYMBDDR_LEN*SLOT_SYMB_NUM + (j-1)*ANT_NUM*SYMBDDR_LEN + (k-1)*SYMBDDR_LEN + (1:len));
        end     
   end
end  

i=19;j=1;k=60*12;
  ul_st = SlotSymNum*(i-1)+ SYMBX_LEN*(j-1) + (j>1)*(SYMB0_LEN-SYMBX_LEN);
             if j == 1
                len = SYMB0_LEN;
             else
                len = SYMBX_LEN;
             end
% plot(abs(AntData(ul_st+(1:len),1)))
bar(abs(AntData(ul_st+(1:len),1)));
ANT_Data1=AntData(ul_st+(1:k),1);
ANT_Data3=AntData(ul_st+(k:len),1);
% plot(abs(ANT_Data1))
% ANT_Data1_real=real(ANT_Data1);    
% ANT_Data1_imag=imag(ANT_Data1);   
mean_pwr1= mean(ANT_Data1.*conj(ANT_Data1));
mean_pwr3= mean(ANT_Data3.*conj(ANT_Data3));
db_pwr1=10*log10(mean_pwr1);
db_pwr3=10*log10(mean_pwr3);