clc;                        %清理命令行窗口
clear all;                  %清理工作区
RGB=imread('cup.jpg');     %使用imread函数读取图片数据
[ROW,COL,D]=size(RGB);      %图片行,列,维度
R=RGB(:,:,1);               %提取图片中的红色分量
G=RGB(:,:,2);               %提取图片中的绿色分量
B=RGB(:,:,3);               %提取图片中的蓝色分量
imgdata=zeros(1,ROW*COL);   %定义一个初值为0的数组,存储转换后的图片数据
for r=1:ROW
	for c=1:COL
       imgdata((r-1)*COL+c)=bitand(R(r,c),224)+bitshift(bitand(G(r,c),224),-3)+bitshift(bitand(B(r,c),192),-6);
	end
end

fidc=fopen('cup.txt','w+');
for i =1:ROW*COL
        fprintf(fidc,'%02x ',imgdata(i));
end
fclose(fidc);



