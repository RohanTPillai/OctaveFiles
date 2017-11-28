%%%%%%%%%% Windowed Peak detection Code - Purely So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% Edits 
% Implementation of functions for the smallest possible work to make the code manageable

clc
clear all
%close all

%% Read the data from the CSV file
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\christine  23 kmoch.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Jayesh Acharya.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Jitendra_Acharya 1.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Manisha Acharya.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Mohan Acharya.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Exercise\Atharv Kulkarni  Fast ex.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Exercise\Pranav Mehta EX 2.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Exercise\Sujat LEle ex.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Exercise\Sujat Lele.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Inge\Inge Resting 2.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Inge\Inge Resting.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Inge\Inge Sarva 2 (2).csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Leena Phadke\LEENA_PHADKE.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika dogpose.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika paschimotanasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika resting.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika sarvangasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shavasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shisasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika tadasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika virbhadrasana I.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\brigitte  subject 25.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\diana  subject 19.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\florian  subject 24.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\gudrun  subject 22.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\hanni  subject 1.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\inge  subject 18.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\irene  subject 21.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\sabine  subject 15.csv');
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\susann  14.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\Ulrich  Genzler.csv');



%% Manage Inverted/Non-Inverted Signal
c = data(:,3);
data_invert_flag = 0;                                                           % 1 if data is to be inverted, else 0
c = InvertSignal(c,data_invert_flag);
c_length = length(c);

initial_param = 10;
reduced_param = 7;


%% Low pass filtering the signal
%window_size = 60;
%c = Apply_Moving_Avg_Filt(c,window_size,c_length);

%% Get RRI Ground truth from CSV file
%[RRI_true_val,RRI_true_val_locs] = GetTrueRRI(data(:,4));

%% Calculating onset and R locations, their heights and respective confidence factors
[onset_pks,onset_locs,R_pks,R_locs,final_conf_fac,high_RRI_count,slope,slope_thresholds] = ComputeLocsPksAndCF(c,c_length,initial_param,reduced_param);

% Debug
%  max_slope = max(slope);

%% For plotting the R loc confidence factors
final_R_low = R_locs(find(final_conf_fac == 20));
final_R_good = R_locs(find(final_conf_fac == 60));
final_R_high = R_locs(find(final_conf_fac == 100));
final_R_low_markers = (max(c))*ones(1,length(final_R_low));
final_R_good_markers = (max(c)+20)*ones(1,length(final_R_good));
final_R_high_markers = (max(c)+40)*ones(1,length(final_R_high));

% Calculating the algorithm confidence
algo_conf_fac = CalcConfidenceFactor(final_R_low,high_RRI_count,R_locs);

% Exporting the data to csv file
%[RRI_for_CSV,conf_fac_for_CSV] = CalcRRIForCSV(c,R_locs,final_conf_fac);
%data_to_write = [(1:length(c))',c,RRI_for_CSV',conf_fac_for_CSV'];
%csvwrite('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\1. Single Lead New Algo Results\Ulrich  Genzler Lead 1.csv',data_to_write);

% Plots of obtained waveforms
figure;
plot(c);
hold on
plot(R_locs,R_pks,'marker','v', 'color', 'g', 'MarkerSize', 6);
hold on
plot(final_R_high,  final_R_high_markers,'marker','v', 'color', 'r', 'MarkerSize', 4);
hold on
plot(final_R_good,final_R_good_markers,'marker','v', 'color', 'c', 'MarkerSize', 4);
hold on
plot(final_R_low,final_R_low_markers,'marker','v', 'color', 'k', 'MarkerSize', 4);
hold on
plot(slope);
hold on
plot(onset_locs,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);

title(['R-Point Detection based QRS Detection with ' num2str(algo_conf_fac,4) '% Confidence Factor']);

%figure
%plot(slope);

% Calculation of actual RRI artifacts and ectopic values obtained from the csv file
%RRI_true_val = RRI_true_val';
%RRI_true_val_locs = RRI_true_val_locs';
%RRI_true_val_ectopic1 = find((RRI_true_val < 700 & RRI_true_val > 100));
%RRI_true_val_ectopic2 = find((RRI_true_val > 1400 & RRI_true_val < 2000));
%RRI_true_val_ectopic = RRI_true_val_locs([RRI_true_val_ectopic1 RRI_true_val_ectopic2]);
%RRI_true_val_ectopic_markers = (max(RRI_true_val)+10)*ones(1,length(RRI_true_val_ectopic));
%RRI_true_val_artifact1 = find(RRI_true_val < 100);
%RRI_true_val_artifact2 = find(RRI_true_val > 2000); 
%RRI_true_val_artifact = RRI_true_val_locs([RRI_true_val_artifact1 RRI_true_val_artifact2]);
%RRI_true_val_artifact_markers = (max(RRI_true_val)+50)*ones(1,length(RRI_true_val_artifact)); 
    
% Plots of obtained waveforms
%figure; 
%plot(c);
%hold on
%plot(onset_locs,onset_pks,'marker','v','color', 'r', 'MarkerSize', 6);
%hold on
%plot(R_locs,R_pks,'marker','v', 'color', 'g', 'MarkerSize', 6);
%hold on
%plot(slope);
%hold on
%plot(onset_locs,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);
%hold on
%plot(RRI_artifact, RRI_artifact_markers,'marker','v', 'MarkerSize', 6);
%hold on
%plot(RRI_ectopic, RRI_ectopic_markers,'marker','v','MarkerSize', 6);
%title('R-Point Detection based QRS Detection');
