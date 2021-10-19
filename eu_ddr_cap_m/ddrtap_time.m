% clear all;  
close all;
% clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
catch_symb_num=280;
SYMB0_LEN=4448;
SYMBX_LEN=4384;
SYMBDDR_LEN =4464;
% SLOT_LEN =61440*4;
SLOT_SYMB_NUM=14;
ANT_NUM =4;
SLOT_NUM = catch_symb_num/SLOT_SYMB_NUM;
SlotSymNum = (SYMB0_LEN+SYMBX_LEN*13);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
filename = 'E:\matlab\cap_dl_td_4109\dl_t2_ddr_data.txt';
%filename = 'EU_DDR_DATA\ddr_dat_mcs20_2dmrs.txt';
%filename = 'EU_DDR_DATA\ddr_timedata_1frm.txt';
a=textread(filename,'%s')';
b = char([]);

for i=1:length(a)
   b(:,i) = a{i};
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

%         slot_len = 61440;
%         slot_id = 0;
%         slot0 = AntData(slot_len*slot_id+1:slot_len*(slot_id+1),1);
%         slot_id = 1;
%         slot1 = AntData(slot_len*slot_id+1:slot_len*(slot_id+1),1);
%         slot_id = 2;
%         slot2 = AntData(slot_len*slot_id+1:slot_len*(slot_id+1),1);
%         slot_id = 3;
%         slot3 = AntData(slot_len*slot_id+1:slot_len*(slot_id+1),1);
%         
%         ul_slot = [slot0',slot1',slot2',slot3'];
%         plot(   abs(ul_slot)  );
%         figure;
        plot(  20*log10( abs(AntData(:,1)) )  );

% for i = 1:20
%     Slot_Ant_Data(:,i)= AntData((i-1)*61440+1:i*61440,1);
%     subplot(4,5,i)
%     plot(  20*log10( abs(Slot_Ant_Data(:,i)) )  );
%     title(['slotid =',num2str(i)])
% end 
% 
% j = 0;
% for i = 1:61440
%     if( abs(Slot_Ant_Data(i,20)) == 0 )
%         j = j + 1;
%         zero_idx(j)= i;
%     end  
% end    
% 
% i=19;j=1;
%   ul_st = SlotSymNum*(i-1)+ SYMBX_LEN*(j-1) + (j>1)*(SYMB0_LEN-SYMBX_LEN);
%              if j == 1
%                 len = SYMB0_LEN;
%              else
%                 len = SYMBX_LEN;
%              end
% % plot(abs(AntData(ul_st+(1:len),1)))
% ANT_Data1=zeros(SlotSymNum*SLOT_NUM,1);
% ANT_Data1=AntData(ul_st+(1:len),1);
% ANT_Data3=AntData(ul_st+(1:len),3);
% % plot(abs(ANT_Data1))
% % ANT_Data1_real=real(ANT_Data1);    
% % ANT_Data1_imag=imag(ANT_Data1);   
% mean_pwr1= mean(ANT_Data1.*conj(ANT_Data1));
% mean_pwr3= mean(ANT_Data3.*conj(ANT_Data3));
% db_pwr1=10*log10(mean_pwr1);
% db_pwr3=10*log10(mean_pwr3);