function [cpx_pc,d_ang_min]=DecodeDMRS(cpx)
%% this function is decode dmrs
p0=cpx(1:2:end);
p1=cpx(2:2:end);
fprintf("Decode port 1001 DMRS\n");
[cpx_pc(:,1),d_ang_min(:,1)]=DecodeSingleDMRS(p0);
fprintf("Decode port 1003 DMRS\n");
[cpx_pc(:,2),d_ang_min(:,2)]=DecodeSingleDMRS(p1);
end