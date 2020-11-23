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
 a=IQ0(1:len_frame);
 IQ2=reshape(a,len_sym*len_IQ,No_slot*14);
 IQ=IQ2(1:2:end,:)+1i.*IQ2(2:2:end,:);
 