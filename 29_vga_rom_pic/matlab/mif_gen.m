clear               %清理命令行窗口
clc                 %清理工作区

% 使用imread函数读取图片,并转化为三维矩阵
image_array = imread('logo.bmp');

% 使用size函数计算图片矩阵三个维度的大小
% 第一维为图片的高度，第二维为图片的宽度，第三维为图片维度
[height,width,z]=size(image_array);   % 100*100*3
red   = image_array(:,:,1); % 提取红色分量，数据类型为uint8
green = image_array(:,:,2); % 提取绿色分量，数据类型为uint8
blue  = image_array(:,:,3); % 提取蓝色分量，数据类型为uint8

% 使用reshape函数将各个分量重组成一个一维矩阵
%为了避免溢出,将uint8类型的数据扩大为uint32类型
r = uint32(reshape(red'   , 1 ,height*width));
g = uint32(reshape(green' , 1 ,height*width));
b = uint32(reshape(blue'  , 1 ,height*width));

% 初始化要写入.mif文件中的RGB颜色矩阵
rgb=zeros(1,height*width);

% 导入的图片为24bit真彩色图片,每个像素占用24bit,RGB888
% 将RGB888转换为RGB565
% 红色分量右移3位取出高5位,左移11位作为ROM中RGB数据的第15bit到第11bit
% 绿色分量右移2位取出高6位,左移5位作为ROM中RGB数据的第10bit到第5bit
% 蓝色分量右移3位取出高5位,左移0位作为ROM中RGB数据的第4bit到第0bit
for i = 1:height*width
    rgb(i) = bitshift(bitshift(r(i),-3),11)+ bitshift(bitshift(g(i),-2),5)+ bitshift(bitshift(b(i),-3),0);
end

fid = fopen( 'image.mif', 'w+' );

% .mif文件字符串打印
fprintf( fid, 'WIDTH=16;\n');
fprintf( fid, 'DEPTH=%d;\n\n',height*width);

fprintf( fid, 'ADDRESS_RADIX=UNS;\n');
fprintf( fid, 'DATA_RADIX=HEX;\n\n');

fprintf(fid,'%s\n\t','CONTENT');
fprintf(fid,'%s\n','BEGIN');

% 写入图片数据
for i = 1:height*width
    fprintf(fid,'\t\t%d\t:%x\t;\n',i-1,rgb(i));
end

% 打印结束字符串
fprintf(fid,'\tEND;');

fclose( fid ); % 关闭文件指针