fid0 = fopen('./sincoe.txt', 'r');%%%%1024
sin_data = fscanf(fid0, '%d', inf);
fclose (fid0);
figure
plot(sin_data);

fid0 = fopen('./coscoe.txt', 'r');%%%%1024
cos_data = fscanf(fid0, '%d', inf);
fclose (fid0);
figure
plot(cos_data);
