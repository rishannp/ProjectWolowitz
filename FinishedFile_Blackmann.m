%% Preliminary tests seem to need to clear system memory in order to actually keep all the incoming data
clear all
%clearvars -except trainedClassifier validationAccuracy %Try use this so
%you dont have to keep retraining everytime you run the code
clear clc

x=serial('COM4','BaudRate', 9600);

%% Load Classification model for classing
load('BlackmannTrainingData'); % Load the data file with training data for
%%Preprocessing
Z = FeatureExtractedData;
[trainedClassifier, validationAccuracy] = kNN89(Z); % Choose between
%%tree89(Z) model or kNN89(Z) model

%% instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();

%% resolve a stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); end

%% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});

disp('Now receiving chunked data...');
while true
    % get chunk from the inlet
    [chunk,stamps] = inlet.pull_chunk();
    for s=1:length(stamps)
        % and display it
%         fprintf('%.1f\t',chunk(:,s));
        
        %% Store
        
        sz = [100000 4];
        sv = [4 100000];
        
        data = [];
        %data = zeros(sv);
        % T = array2table(chunk,'VariableNames',{'column_1','column_2','column_3','column_4'});
        data = horzcat(chunk,data);
        data = transpose(data);
        
        %% Pre-processing
        %Bandpass using a Blackman window (Works to detrend and denoise and create
        %smoother waveforms
        Fs =200;
        fh = 10/Fs; %Upper bound cutoff
        fl = 9/Fs;  %Lower Bound cutoff
        L = 129; % Number of weights
        k = -floor(L/2):-1; %rounds each element of L/2 to the nearest integer less than or equal to that element all the way to -1 and constructs for -ve b[k]
        c = sin(2*pi*fh*k)./(pi*k)-sin(2*pi*fl*k)./(pi*k); %Negative b[k] filter impulse
        c = [c 2*(fh-fl), fliplr(c)]; %rest of the b[k]
        c = c .* blackman(L)'; % Multiplication of the previous output and a blackman window.
        
        c1 = conv(data(:,1),c,'same'); %Filter data by convolving the original signal and c
        c2 = conv(data(:,2),c,'same'); %Filter data by convolving the original signal and c
        c3 = conv(data(:,3),c,'same'); %Filter data by convolving the original signal and c
        c4 = conv(data(:,4),c,'same'); %Filter data by convolving the original signal and c
        
        %% Moving RMS (Square then mean then root) 5 point centered moving RMS (1-5, 2-6, 3-7 etc)
        C1 = sqrt(movmean(c1 .^ 2, 5));
        C2 = sqrt(movmean(c2 .^ 2, 5));
        C3 = sqrt(movmean(c3 .^ 2, 5));
        C4 = sqrt(movmean(c4 .^ 2, 5));
        
        column_ = horzcat(C1,C2,C3,C4); %Name it column_ unless i change the training data variable
        
        %% Putting data in table/matrix (Depends on need) for proper classification
        %        T2 = array2table(column_);
        
        %         T3 = table(([0;0;0;0]),[0;0;0;0],...
        %             [0;0;0;0],[0;0;0;0],...
        %             'VariableNames',{'column_1','column_2','column_3','column_4'});
        
        T3 = zeros([3 4]);
        
        T3 = [T3;column_];
        
        
        %% Classification
               yfit = trainedClassifier.predictFcn(T3);
        
        %         fprintf('%.1f\t',yfit(end));
        %         fprintf('%.1f\n',s);
        
        %% MATLAB Code for Serial Communication with Arduino
        fclose(instrfind);
        delete(instrfind);
        x=serial('COM4','BaudRate', 9600);
        fopen(x)
        go = true;
        while go
            
            %a = input('Enter 0:6 to turn ON LED or 7 to exit, press: ');
            fwrite(x, yfit, 'char');
            if (a == 7)
                go=false;
            end
        end
        fclose(x)
        fclose(x)

    end
    pause(0.005); %200Hz refresh rate, still unsure how the pipeline works, but as far as i understand this should take the data at the same rate that its being sampled by the ganglion, therefore minimal latency?
    %pause(0.5);
end