% DDR data reader
function AntData=readDDRData(filename,tFlag)
%% read data from csv files
if nargin==0
    filename = '~/Downloads/t0_ddr_data.txt';
    tFlag=0;
elseif nargin==1
    tFlag=1;
end
bitWidth=16;
%% set parameter
if tFlag==1
    catch_symb_num=280;
    SYMB0_LEN=4448;
    SYMBX_LEN=4384;
    SYMBDDR_LEN =4464;
    % SLOT_LEN =61440*4;
else
    catch_symb_num=280;
    SYMB0_LEN=3276;
    SYMBX_LEN=3276;
    SYMBDDR_LEN =4464;
    % SLOT_LEN =61440*4;
end
SLOT_SYMB_NUM=14;
ANT_NUM =4;
SLOT_NUM = catch_symb_num/SLOT_SYMB_NUM;
SlotSymNum = (SYMB0_LEN+SYMBX_LEN*13);

%% read file
% a=readtable(filename,'Delimiter',' ','ReadVariableNames',false);
%conver 32bit data to IQ data
fID = fopen(filename,'r');
IQ=fscanf(fID,'%4x%4x');
I0=IQ(1:2:end);
Q0=IQ(2:2:end);

% c(find(c>= 2^15)) = c(find(c>= 2^15)) -2^16;%(把15,16替换成你想要的位数就可以了)
pos=I0>=2^(bitWidth-1);
I0(pos)=I0(pos)-2^(bitWidth);
pos=Q0>=2^(bitWidth-1);
Q0(pos)=Q0(pos)-2^(bitWidth);

IQ = I0 + 1i*Q0;
%% reshape data
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
            AntData(start_pos+(1:len),k) = IQ((i-1)*ANT_NUM*SYMBDDR_LEN*SLOT_SYMB_NUM + (j-1)*ANT_NUM*SYMBDDR_LEN + (k-1)*SYMBDDR_LEN + (1:len));
        end
    end
end


end
