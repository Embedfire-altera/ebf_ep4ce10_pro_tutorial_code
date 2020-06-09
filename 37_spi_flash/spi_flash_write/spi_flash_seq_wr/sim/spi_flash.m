fid=fopen('spi_flash.txt','w+');
for i =1:10
    for j = 10:19
        fprintf(fid,'%02x ',j-1);
    end
end
fclose(fid);
