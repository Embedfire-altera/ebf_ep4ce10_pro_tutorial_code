clc;                        %���������д���
clear all;                  %��������
% RGB=imread('logo.bmp');     %ʹ��imread������ȡͼƬ����
% [ROW,COL,D]=size(RGB);      %ͼƬ��,��,ά��
% R=RGB(:,:,1);               %��ȡͼƬ�еĺ�ɫ����
% G=RGB(:,:,2);               %��ȡͼƬ�е���ɫ����
% B=RGB(:,:,3);               %��ȡͼƬ�е���ɫ����
% imgdata=zeros(1,ROW*COL);   %����һ����ֵΪ0������,�洢ת�����ͼƬ����
% %ת��ΪRGB332��ʽ
% for r=1:ROW
	% for c=1:COL
       % imgdata((r-1)*COL+c)=bitand(R(r,c),224)+bitshift(bitand(G(r,c),224),-3)+bitshift(bitand(B(r,c),192),-6);
	% end
% end
%�򿪻�����txt�ļ�,����ʽת����ɵ�����д��txt�ļ�
fidc=fopen('data_test.txt','w+');
for i =1:100
    for j =1:100
        fprintf(fidc,'%02x ',j);
    end
end
fclose(fidc);



