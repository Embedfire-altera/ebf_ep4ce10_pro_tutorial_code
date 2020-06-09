clc;                            %清理命令行窗口
clear all;                      %清理工作区
image = imread('logo.png');     %使用imread函数读取图片数据
figure;
imshow(image);                  %窗口显示图片
R = image(:,:,1);               %提取图片中的红色层生成灰度图像
figure;
imshow(R);                      %窗口显示灰色图像
[ROW,COL] = size(R);            %灰色图像大小参数
data = zeros(1,ROW*COL);        %定义一个初值为0的数组,存储转换后的图片数据
for r = 1:ROW
    for c = 1 : COL
        data((r-1)*COL+c) = bitshift(R(r,c),-5);    %红色层数据右移5位
    end
end
fid = fopen('logo.txt','w+');                       %打开或新建一个txt文件
for i = 1:ROW*COL;
    fprintf(fid,'%02x ',data(i));                   %写入图片数据
end
fclose(fid);