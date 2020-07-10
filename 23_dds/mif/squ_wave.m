clc;                    %�������������
clear all;              %�������������,�ͷ��ڴ�ռ�
F1=1;                   %�ź�Ƶ��
Fs=2^12;                %����Ƶ��
P1=0;                   %�źų�ʼ��λ
N=2^12;                 %��������
t=[0:1/Fs:(N-1)/Fs];    %����ʱ��
ADC=2^7 - 1;            %ֱ������
A=2^7;                  %�źŷ���
%���ɷ����ź�
s=A*square(2*pi*F1*t + pi*P1/180) + ADC;
plot(s);                %����ͼ��
%����mif�ļ�
fild = fopen('squ_wave_4096x8.mif','wt');
%д��mif�ļ�ͷ
fprintf(fild, '%s\n','WIDTH=8;');           %λ��
fprintf(fild, '%s\n\n','DEPTH=4096;');      %���
fprintf(fild, '%s\n','ADDRESS_RADIX=UNS;'); %��ַ��ʽ
fprintf(fild, '%s\n\n','DATA_RADIX=UNS;');  %���ݸ�ʽ
fprintf(fild, '%s\t','CONTENT');            %��ַ
fprintf(fild, '%s\n','BEGIN');              %��ʼ
for i = 1:N
    s0(i) = round(s(i));    %��С������������ȡ��
    if s0(i) <0             %��1ǿ������
        s0(i) = 0
    end
    fprintf(fild, '\t%g\t',i-1+N);  %��ַ����
    fprintf(fild, '%s\t',':');      %ð��
    fprintf(fild, '%d',s0(i));      %����д��
    fprintf(fild, '%s\n',';');      %�ֺţ�����
end
fprintf(fild, '%s\n','END;');       %����
fclose(fild);