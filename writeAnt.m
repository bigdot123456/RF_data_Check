%% generate test data for float data
function data_fixed=writeAnt(filename,data)
 f0=fopen(filename,'wb');
 data_fixed0=ceil(data);
 data_fixed=mod(data_fixed0,2^15);
 fwrite(f0,data_fixed,'int16');
 fclose(f0);