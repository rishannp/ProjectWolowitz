%% Try 1
% clear all;
% a = arduino('COM4','Mega2560','Libraries','Adafruit/MotorShieldV2');
% clear s;
% s = servo(a, 'D48', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
% for angle = 0:0.2:1
%     writePosition(s, angle);
%     current_pos = readPosition(s);
%     current_pos = current_pos*180;
%     fprintf('Current motor position is %d degrees\n', current_pos);
%     pause(2);
% end
%% Different Try
%fopen(a);
%fwrite(a, [12]);
%writeDigitalPin(a, 'D8', 1);
%fclose(a);
% shield = addon(a, 'Adafruit/MotorShieldV2');
% addrs = scanI2CBus(a,0);
%  s = servo(shield,2);
%  writePosition(s,1);
%  
 
% for i = 0:8:4096
%     for servo = 1:4
%         shield.setPWM(servo,0,i+mod((4096/16)*servo,4096))
%     end
% end

%% Simple Try
%  clear all; clear clc;
%  x = 4;
%  global s;
%  s = serialport("COM4",9600);
%  write(s,x,"int16");
 
%% Try 4

% clear all;
% x=4;
% global s;
% s = serial('COM4');
% fopen(s);
% fprintf(s,x);
% fclose(s);

%%  Try 5 -- WORKS WORKS WORKS

%MATLAB Code for Serial Communication with Arduino
fclose(instrfind);
delete(instrfind);
x=serial('COM4','BaudRate', 250000);
fopen(x)
go = true;
while go
    
    a = input('Enter 0:6 to turn ON LED or 7 to exit, press: ');
    
        if (a(:,end) == 0)
        a(:,1:100) = 0;
        a = transpose(a);
        end
        if (a(:,end) == 1)
        a(:,1:100) = 1;
        a = transpose(a);
        end
        if (a(:,end) == 2)
        a(:,1:100) = 2;
        a = transpose(a);
        end
        if (a(:,end) == 3)
        a(:,1:100) = 3;
        a = transpose(a);
        end
        if (a(:,end) == 4)
        a(:,1:100) = 4;
        a = transpose(a);
        end
        if (a(:,end) == 5)
        a(:,1:100) = 5;
        a = transpose(a);
        end
        if (a(:,end) == 6)
        a(:,1:100) = 6;
        a = transpose(a);
        end
        if (a(:,end) == 7)
        a(:,1:100) = 7;
        a = transpose(a);
        end
        
    fwrite(x, a, 'char');
    if (a == 7)
        go=false;
    end
end
fclose(x)
fclose(x)

