fid=fopen('fifo_data.txt','w+');
for i =1:50
    for j = 1:50
        fprintf(fid,'%02x ',j-1);
    end
end
fclose(fid);
