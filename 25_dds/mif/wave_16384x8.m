clc;                    %清除命令行命令
clear all;              %清除工作区变量,释放内存空间
F1=1;                   %信号频率
Fs=2^12;                %采样频率
P1=0;                   %信号初始相位
N=2^12;                 %采样点数
t=[0:1/Fs:(N-1)/Fs];    %采样时刻
ADC=2^7 - 1;            %直流分量
A=2^7;                  %信号幅度
s1=A*sin(2*pi*F1*t + pi*P1/180) + ADC;          %正弦波信号
s2=A*square(2*pi*F1*t + pi*P1/180) + ADC;       %方波信号
s3=A*sawtooth(2*pi*F1*t + pi*P1/180,0.5) + ADC; %三角波信号
s4=A*sawtooth(2*pi*F1*t + pi*P1/180) + ADC;     %锯齿波信号
%创建mif文件
fild = fopen('wave_16384x8.mif','wt');
%写入mif文件头
fprintf(fild, '%s\n','WIDTH=8;');           %位宽
fprintf(fild, '%s\n\n','DEPTH=16384;');     %深度
fprintf(fild, '%s\n','ADDRESS_RADIX=UNS;'); %地址格式
fprintf(fild, '%s\n\n','DATA_RADIX=UNS;');  %数据格式
fprintf(fild, '%s\t','CONTENT');            %地址
fprintf(fild, '%s\n','BEGIN');              %开始
for j = 1:4
    for i = 1:N
        if j == 1       %打印正弦信号数据
            s0(i) = round(s1(i));    %对小数四舍五入以取整
            fprintf(fild, '\t%g\t',i-1);  %地址编码
        end

        if j == 2       %打印方波信号数据
            s0(i) = round(s2(i));    %对小数四舍五入以取整
            fprintf(fild, '\t%g\t',i-1+N);  %地址编码
        end

        if j == 3       %打印三角波信号数据
            s0(i) = round(s3(i));    %对小数四舍五入以取整
            fprintf(fild, '\t%g\t',i-1+(2*N));  %地址编码
        end

        if j == 4       %打印锯齿波信号数据
            s0(i) = round(s4(i));    %对小数四舍五入以取整
            fprintf(fild, '\t%g\t',i-1+(3*N));  %地址编码
        end

        if s0(i) <0             %负1强制置零
            s0(i) = 0
        end
        
        fprintf(fild, '%s\t',':');      %冒号
        fprintf(fild, '%d',s0(i));      %数据写入
        fprintf(fild, '%s\n',';');      %分号，换行
    end
end
fprintf(fild, '%s\n','END;');       %结束
fclose(fild);