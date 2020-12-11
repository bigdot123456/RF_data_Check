function IQ_cpx_abs_db=plotRFSpectrum(Ant_view,num_slot)
%% plot standard RF spectrum
if nargin==1
    num_slot=20;
elseif nargin==0
    fprintf("Should input ant data, run demo with runSlot0 !\n");
    return
end

len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_sym=(4096+len_scp);%% normal cp, should 288, long cp should be 352
len_ts_per_slot=(len_slot*len_sym+len_lcp-len_scp)*len_IQ;
len=len_ts_per_slot*num_slot;

%% mark line parameter
mark_line=-60*ones(len,1);
mark_slot=(1:num_slot-1)*len_ts_per_slot;
mark_line(mark_slot)=0;

mark0_line=-70*ones(len,1);
sym_array=(1:len_slot-1)*len_sym+(len_lcp-len_scp);
sym_array1=repmat(sym_array,num_slot,1);
sym_base=(0:num_slot-1)*len_ts_per_slot;
sym_base1=repmat(sym_base',1,len_slot-1);
mark_sym=sym_base1+sym_array1;
mark_sym1=mark_sym(1:end);
mark0_line(mark_sym1)=0;

%% process IQ_data
IQ_cpx=Ant_view;
IQ_cpx_abs=abs(IQ_cpx);
IQ_cpx_abs_max=max(IQ_cpx_abs);

%plot(IQ_cpx_abs(1:len));
str=sprintf('Plot total %d slot spectrum',num_slot);
figure('NumberTitle', 'on', 'Name', str);
IQ_cpx_abs_db=20*log10(IQ_cpx_abs/IQ_cpx_abs_max);
plot(IQ_cpx_abs_db(1:len));
grid on;
hold on;
plot(mark_line,'r');
plot(mark0_line,'g');
end