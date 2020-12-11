%% read data from bin file
function IQ=readAnt(filename)
 f0=fopen(filename,'rb');
 IQ0=fread(f0,'int16');
 fclose(f0);
 disp(max(IQ0))
 len_IQ=2;
 len_slot=14;
 len_sym=273*12;
 len_ts_per_slot=len_slot*len_sym*len_IQ;
 full_len=length(IQ0);
 No_slot=floor(full_len/len_ts_per_slot);
 len_frame=No_slot*len_ts_per_slot;
 %a=IQ0(1:len_frame);
 %IQ2=reshape(a,len_sym*len_IQ,No_slot*14);
 %IQ=IQ2(1:2:end,:)+1i.*IQ2(2:2:end,:);
 
 Ia=IQ0(1:2:len_frame);
 Qa=IQ0(2:2:len_frame);
 Vstart_slot=2;
 Vstart_sym=12;
 view_Nsym=1;
 Nstart=(14*Vstart_slot+Vstart_sym)*len_sym;
 Nend=view_Nsym*len_sym;
 
 view_range=Nstart:Nstart+Nend;
 
 scatterplot([Ia(view_range),Qa(view_range)]);
 
 IQ_full=Ia+1i*Qa;
 
 IQ=reshape(IQ_full,len_sym,No_slot*14);
 