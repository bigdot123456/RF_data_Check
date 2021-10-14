%% Input RF data, we will offer spectrum & constellation
function ant_bb_array=plotRFConstellation(Ant_view,num_slot)
%% plot slot with time-domain data
if nargin==1
    num_slot=1;
elseif nargin==0
    fprintf("Should input ant data, run demo with runSlot0 !\n");
    return
end
%% get IFFT data
len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
fft_len=4096;
prb_len=3276;
%% get data
len_sym=(fft_len+len_scp);%% normal cp, should 288, long cp should be 352
len_ts_per_slot=(len_slot*len_sym+len_lcp-len_scp)*len_IQ;
len=len_ts_per_slot*num_slot;

ant_slot=Ant_view(1:len);
ant_slot_array=reshape(ant_slot,len_ts_per_slot,num_slot);

%% view every slot
ant_bb_array=zeros(prb_len,len_slot,num_slot);
for i=1:num_slot
    ant_bb_array(:,:,i)=plotSlotConstellation(ant_slot_array(:,i),i-1);
end