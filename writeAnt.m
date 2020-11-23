%% generate test data for float data
function data_fixed=writeAnt(filename,data)
 bit_width=16;
 f0=fopen(filename,'wb');
 x=max(abs(data));
 pos=x==0;
 x(pos)=1;
 data_nz=data;
 data_nz(:,pos)=1;
 data_norm=data_nz./x;
 data_fixed0=ceil(data_norm*2^(bit_width-1));
 pos1=data_fixed0==2^(bit_width-1);
 data_fixed=data_fixed0;
 data_fixed(pos1)=2^(bit_width-1)-1;
 fwrite(f0,data_fixed,'int16');
 fclose(f0);