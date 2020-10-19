clc;                    %�������������
clear all;              %�������������,�ͷ��ڴ�ռ�
F1=1;                   %�ź�Ƶ��
Fs=2^12;                %����Ƶ��
P1=0;                   %�źų�ʼ��λ
N=2^12;                 %��������
t=[0:1/Fs:(N-1)/Fs];    %����ʱ��
ADC=2^7 - 1;            %ֱ������
A=2^7;                  %�źŷ���
s1=A*sin(2*pi*F1*t + pi*P1/180) + ADC;          %���Ҳ��ź�
s2=A*square(2*pi*F1*t + pi*P1/180) + ADC;       %�����ź�
s3=A*sawtooth(2*pi*F1*t + pi*P1/180,0.5) + ADC; %���ǲ��ź�
s4=A*sawtooth(2*pi*F1*t + pi*P1/180) + ADC;     %��ݲ��ź�
%����mif�ļ�
fild = fopen('wave_16384x8.mif','wt');
%д��mif�ļ�ͷ
fprintf(fild, '%s\n','WIDTH=8;');           %λ��
fprintf(fild, '%s\n\n','DEPTH=16384;');     %���
fprintf(fild, '%s\n','ADDRESS_RADIX=UNS;'); %��ַ��ʽ
fprintf(fild, '%s\n\n','DATA_RADIX=UNS;');  %���ݸ�ʽ
fprintf(fild, '%s\t','CONTENT');            %��ַ
fprintf(fild, '%s\n','BEGIN');              %��ʼ
for j = 1:4
    for i = 1:N
        if j == 1       %��ӡ�����ź�����
            s0(i) = round(s1(i));    %��С������������ȡ��
            fprintf(fild, '\t%g\t',i-1);  %��ַ����
        end

        if j == 2       %��ӡ�����ź�����
            s0(i) = round(s2(i));    %��С������������ȡ��
            fprintf(fild, '\t%g\t',i-1+N);  %��ַ����
        end

        if j == 3       %��ӡ���ǲ��ź�����
            s0(i) = round(s3(i));    %��С������������ȡ��
            fprintf(fild, '\t%g\t',i-1+(2*N));  %��ַ����
        end

        if j == 4       %��ӡ��ݲ��ź�����
            s0(i) = round(s4(i));    %��С������������ȡ��
            fprintf(fild, '\t%g\t',i-1+(3*N));  %��ַ����
        end

        if s0(i) <0             %��1ǿ������
            s0(i) = 0
        end
        
        fprintf(fild, '%s\t',':');      %ð��
        fprintf(fild, '%d',s0(i));      %����д��
        fprintf(fild, '%s\n',';');      %�ֺţ�����
    end
end
fprintf(fild, '%s\n','END;');       %����
fclose(fild);