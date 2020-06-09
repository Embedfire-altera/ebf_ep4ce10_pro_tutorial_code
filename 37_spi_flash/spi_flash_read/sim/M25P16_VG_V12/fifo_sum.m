fid=fopen('data.txt','w+');
for i =1:256
    for j = 1:256
        fprintf(fid,'%02x ',j-1);
    end
end
fclose(fid);
