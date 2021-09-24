% DDR data reader
function AntData=readDDRData(filename,tFlag)
%% read data from csv files
if nargin==0
    filename = 'iladata.txt';
    tFlag=0;
elseif nargin==1
    tFlag=1;
end

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

a=textscan(filename,'%s');
b = char([]);

for i=1:length(a)
    b(i,:)=a{i};
end
%  b1=reshape(b,4,[]).';

u16_b = hex2dec(reshape(b,4,[]).');
s16_b = (u16_b >=32768 ).*(u16_b-2^16)+(u16_b < 32768 ).*(u16_b);

c_b = s16_b(2:2:end) + s16_b(1:2:end)*sqrt(-1);
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
            AntData(start_pos+(1:len),k) = c_b((i-1)*ANT_NUM*SYMBDDR_LEN*SLOT_SYMB_NUM + (j-1)*ANT_NUM*SYMBDDR_LEN + (k-1)*SYMBDDR_LEN + (1:len));
        end
    end
end


end