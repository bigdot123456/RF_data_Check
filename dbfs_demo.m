%% caculate dbfs & scale value
dbfs=-15;
dbscale=2^15*10^(dbfs/20);
fprintf('dbfs:%d=%d\n',dbfs,dbscale);
