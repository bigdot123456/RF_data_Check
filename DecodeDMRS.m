function [cpx_pc,fc]=DecodeDMRS(cpx)
%% this function is decode dmrs; output is cpx phase compensate result; fc is frequency error!
p0=cpx(1:2:end);
p1=cpx(2:2:end);
fprintf("Decode port 1001 DMRS\n");
fc=zeros(1,2);
[cpx_pc(:,1),fc(:,1)]=DecodeSingleDMRS(p0);
fprintf("Decode port 1003 DMRS\n");
[cpx_pc(:,2),fc(:,2)]=DecodeSingleDMRS(p1);
end