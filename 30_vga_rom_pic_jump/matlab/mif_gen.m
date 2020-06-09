clear               %���������д���
clc                 %��������

% ʹ��imread������ȡͼƬ,��ת��Ϊ��ά����
image_array = imread('logo.bmp');

% ʹ��size��������ͼƬ��������ά�ȵĴ�С
% ��һάΪͼƬ�ĸ߶ȣ��ڶ�άΪͼƬ�Ŀ�ȣ�����άΪͼƬά��
[height,width,z]=size(image_array);   % 100*100*3
red   = image_array(:,:,1); % ��ȡ��ɫ��������������Ϊuint8
green = image_array(:,:,2); % ��ȡ��ɫ��������������Ϊuint8
blue  = image_array(:,:,3); % ��ȡ��ɫ��������������Ϊuint8

% ʹ��reshape�������������������һ��һά����
%Ϊ�˱������,��uint8���͵���������Ϊuint32����
r = uint32(reshape(red'   , 1 ,height*width));
g = uint32(reshape(green' , 1 ,height*width));
b = uint32(reshape(blue'  , 1 ,height*width));

% ��ʼ��Ҫд��.mif�ļ��е�RGB��ɫ����
rgb=zeros(1,height*width);

% �����ͼƬΪ24bit���ɫͼƬ,ÿ������ռ��24bit,RGB888
% ��RGB888ת��ΪRGB565
% ��ɫ��������3λȡ����5λ,����11λ��ΪROM��RGB���ݵĵ�15bit����11bit
% ��ɫ��������2λȡ����6λ,����5λ��ΪROM��RGB���ݵĵ�10bit����5bit
% ��ɫ��������3λȡ����5λ,����0λ��ΪROM��RGB���ݵĵ�4bit����0bit
for i = 1:height*width
    rgb(i) = bitshift(bitshift(r(i),-3),11)+ bitshift(bitshift(g(i),-2),5)+ bitshift(bitshift(b(i),-3),0);
end

fid = fopen( 'image.mif', 'w+' );

% .mif�ļ��ַ�����ӡ
fprintf( fid, 'WIDTH=16;\n');
fprintf( fid, 'DEPTH=%d;\n\n',height*width);

fprintf( fid, 'ADDRESS_RADIX=UNS;\n');
fprintf( fid, 'DATA_RADIX=HEX;\n\n');

fprintf(fid,'%s\n\t','CONTENT');
fprintf(fid,'%s\n','BEGIN');

% д��ͼƬ����
for i = 1:height*width
    fprintf(fid,'\t\t%d\t:%x\t;\n',i-1,rgb(i));
end

% ��ӡ�����ַ���
fprintf(fid,'\tEND;');

fclose( fid ); % �ر��ļ�ָ��