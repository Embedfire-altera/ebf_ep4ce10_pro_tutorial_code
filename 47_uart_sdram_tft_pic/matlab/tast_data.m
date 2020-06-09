fid=fopen('test_data.txt','w+');
for i =1:512
    for j = 1:255
        fprintf(fid,'%02x ',j-1);
    end
end
fclose(fid);
