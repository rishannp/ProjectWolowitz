clear all

s = arduino('COM4','Mega2560','Libraries','Adafruit/MotorShieldV2');

y = 1000;

%for z = 1:1:y
prompt = 'Pick a Number' ; 
clsfr = input(prompt);

a = 0;
b = 1;
c = 2;
d = 3;
e = 4;
f = 5;

if clsfr == a    % Resting
    h = servo(s, 'D52', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    i = servo(s, 'D50', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    j = servo(s, 'D48', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    k = servo(s, 'D46', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    l = servo(s, 'D44', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);

    angle = 0.2;
    writePosition(h, angle);
    writePosition(i, angle);
    writePosition(j, angle);
    writePosition(k, angle);
    writePosition(l, angle);
    
    clear h
    clear i
    clear j
    clear k
    clear l
    
elseif clsfr == b   % Thumb
    h = servo(s, 'D52', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    angle = 1;
    writePosition(h, angle);
    angle = 0;
    writePosition(h,angle);
    
    clear h
elseif clsfr == c       % Pinky
    i = servo(s, 'D50', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    angle = 1;
    writePosition(i, angle);
    
    clear i
        
elseif clsfr == d      %Ring
    j = servo(s, 'D48', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    angle = 1;
    writePosition(j, angle);
    angle = 0;
    writePosition(j,angle);
    
    clear j
    
elseif clsfr == e         %Middle
    k = servo(s, 'D46', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    angle = 1;
    writePosition(k, angle);
    angle = 0;
    writePosition(k,angle);
    
    clear k
    
elseif clsfr == f          %Index
    l = servo(s, 'D44', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    angle = 1;
    writePosition(l, angle);
    angle = 0;
    writePosition(l,angle);
    
    clear l
    
%end

end