fid=fopen('data_test.txt','w+');
for i =1:200
    for j = 1:50
        fprintf(fid,'%02x ',j-1);
    end
end
fclose(fid);
