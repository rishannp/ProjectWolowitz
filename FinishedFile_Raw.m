%% Preliminary tests seem to need to clear system memory in order to actually keep all the incoming data
clear all
%clearvars -except trainedClassifier validationAccuracy %Try use this so
%you dont have to keep retraining everytime you run the code
clear clc

x=serial('COM4','BaudRate', 9600);

%% Load Classification model's for classing
load('RawTrainingData'); % Load the data file with training data for
%%Preprocessing
Z = FeatureExtractedData;
[trainedClassifier, validationAccuracy] = kNN92(Z); % Choose between
%%tree88(Z) model or kNN92(Z) model

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
        fs = 200;
        
        wo = 50/(fs/2);
        bw = wo/15;
        [b,a] = iirnotch(wo,bw);  % Notch Filter at 50Hz
        
        NotchData=filter(b,a,data(:,1:2:3:4));
        
        ProcessedData = bandpass(NotchData(:,1:2:3:4),[7 13],fs); % Bandpass Data at 7-13Hz as BCI Suggests
        
        %% Labelling data as variables
        c1 = ProcessedData(:,1);
        c2 = ProcessedData(:,2);
        c3 = ProcessedData(:,3);
        c4 = ProcessedData(:,4);
        
        
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
        
        T3 = [T3;data];
        
        
        %% Classification
               yfit = trainedClassifier.predictFcn(T3);
        
                %fprintf('%.1f\t',yfit(end));
                %fprintf('%.1f\n',s);
        
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