function [che,cpx_che,cpx_pc]=CHEDMRS(cpx0,cpx1,DMRSParam)
%% this function is decode dmrs
if nargin==0
    fprintf("error with no parameter in");
    fprintf("parameter is:CHEDMRS(cpx0,cpx1,DMRSParam)");
    return 
elseif nargin==1
    cpx1=cpx0;
    indexSlotInFrame=9;
    DMRSSymbolPos=3;
    nSCID=0;
    N_nSCID_ID=1;
    RBMax=273;
elseif nargin==2
    indexSlotInFrame=9;
    DMRSSymbolPos=3;
    nSCID=0;
    N_nSCID_ID=1;
    RBMax=273;
else
    indexSlotInFrame=DMRSParam.indexSlotInFrame;
    DMRSSymbolPos=DMRSParam.DMRSSymbolPos;
    nSCID=DMRSParam.nSCID;
    N_nSCID_ID=DMRSParam.N_nSCID_ID;
    RBMax=DMRSParam.RBMax;
end

global debug_che;
len=length(cpx0)/2;
cpx_pc=zeros(len,4);
%% generate std RS signal
DMRSsignal = DMRS_base_seq_generation(indexSlotInFrame,DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax);

%% decode DMRS
[cpx_pc(:,1:2),ant0_fc]=DecodeDMRS(cpx0);
[cpx_pc(:,3:4),ant1_fc]=DecodeDMRS(cpx1);
%% channel estimation method
% cpx0=H00*ant0+H01*ant1;
% cpx1=H10*ant0+H11*ant1;
sn=0:(len-1);
ant0_pc=exp(1i*sn'.*ant0_fc);
ant1_pc=exp(1i*sn'.*ant1_fc);
che_ant0_0=abs(cpx0(1:2:end)).*ant0_pc(:,1);
che_ant0_1=abs(cpx0(2:2:end)).*ant0_pc(:,2);

che_ant1_0=abs(cpx1(1:2:end)).*ant1_pc(:,1);
che_ant1_1=abs(cpx1(2:2:end)).*ant1_pc(:,2);

h00=upsample(che_ant0_0,2);
h01=upsample(che_ant0_1,2,1);
h10=upsample(che_ant1_0,2);
h11=upsample(che_ant1_1,2,1);

%% coe filter

fir1=[0.0328167719802339 0.0619947055114297 ...
    -0.0521127678851875 -0.0843121169138371 0.295702701484053 ...
    0.599603883398042 0.295702701484053 -0.0843121169138371 ...
    -0.0521127678851875 0.0619947055114297 0.0328167719802339];
fir=2*fir1/sum(fir1); %% to match upsample with X2
fir_taillen=ceil(length(fir1)/2);

%
% if debug_che
%     che00_real=filter(fir,1,real(h00));
%     figure;
%     plot(che00_real(fir_taillen:end),'.b');
%     hold on;
%     plot(real(h00),'.r');
%     grid on;
%     title('use filter function to filter');
% end

%% use convolution to get data;
che00_real=conv(real(h00),fir,'same');
che01_real=conv(real(h01),fir,'same');
che10_real=conv(real(h10),fir,'same');
che11_real=conv(real(h11),fir,'same');
che00_imag=conv(imag(h00),fir,'same');
che01_imag=conv(imag(h01),fir,'same');
che10_imag=conv(imag(h10),fir,'same');
che11_imag=conv(imag(h11),fir,'same');

for i=1:(fir_taillen-1)
    che00_real(i)=real(che_ant0_0(floor((i+1)/2)));
    che01_real(i)=real(che_ant0_1(floor((i+1)/2)));
    che10_real(i)=real(che_ant1_0(floor((i+1)/2)));
    che11_real(i)=real(che_ant1_1(floor((i+1)/2)));
    che00_imag(i)=imag(che_ant0_0(floor((i+1)/2)));
    che01_imag(i)=imag(che_ant0_1(floor((i+1)/2)));
    che10_imag(i)=imag(che_ant1_0(floor((i+1)/2)));
    che11_imag(i)=imag(che_ant1_1(floor((i+1)/2)));
    
    che00_real(end-i+1)=real(che_ant0_0(end-floor((i-1)/2)));
    che01_real(end-i+1)=real(che_ant0_1(end-floor((i-1)/2)));
    che10_real(end-i+1)=real(che_ant1_0(end-floor((i-1)/2)));
    che11_real(end-i+1)=real(che_ant1_1(end-floor((i-1)/2)));
    che00_imag(end-i+1)=imag(che_ant0_0(end-floor((i-1)/2)));
    che01_imag(end-i+1)=imag(che_ant0_1(end-floor((i-1)/2)));
    che10_imag(end-i+1)=imag(che_ant1_0(end-floor((i-1)/2)));
    che11_imag(end-i+1)=imag(che_ant1_1(end-floor((i-1)/2)));

end

if debug_che
    figure;
    plot(che00_real,'.b');
    hold on;
    plot(che00_imag,'.k');
    plot(real(h00),'.c');
    plot(imag(h00),'.m');
    grid on;
    title('che00 conv to filter');
    
    figure;
    plot(che01_real,'.b');
    hold on;
    plot(che01_imag,'.k');
    plot(real(h01),'.c');
    plot(imag(h01),'.m');
    grid on;
    title('che01 conv to filter');
    
    figure;
    plot(che10_real,'.b');
    hold on;
    plot(che10_imag,'.k');
    plot(real(h10),'.c');
    plot(imag(h10),'.m');
    grid on;
    title('che10 conv to filter');
    
    figure;
    plot(che11_real,'.b');
    hold on;
    plot(che11_imag,'.k');
    plot(real(h11),'.c');
    plot(imag(h11),'.m');
    grid on;
    title('che11 conv to filter');
end
%% filter
che00 = che00_real+1i*che00_imag;
che01 = che01_real+1i*che01_imag;
che10 = che10_real+1i*che10_imag;
che11 = che11_real+1i*che11_imag;

che=zeros(2,2,len*2);
cpx_che=zeros(len*2,2);
che(1+0,1+0,:)=che00 ;
che(1+0,1+1,:)=che01 ;
che(1+1,1+0,:)=che10 ;
che(1+1,1+1,:)=che11 ;

for i=1:2*len
    H=che(:,:,i);
    Y=[cpx0(i);cpx1(i)];
    X=H\Y;
    cpx_che(i,:)=X;
end

end