function ila=readILA(filename)
 f0=fopen(filename,'rb');
 IQ0=fread(f0,'int16');
 fclose(f0);
 