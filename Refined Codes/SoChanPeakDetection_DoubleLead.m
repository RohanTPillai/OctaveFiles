%%%%%%%%%% Windowed Peak detection Code - Based on So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% Edits 
% Peak detection (Best of both) using 2 Lead voting has been incorporated

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
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\susann  14.csv');
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\Ulrich  Genzler.csv');

initial_param = 10;
reduced_param = 7;

%% Manage Inverted/Non-Inverted Signal
c1 = data(:,2);
data_invert_flag = 1;                                                           % 1 if data is to be inverted, else 0
c1 = InvertSignal(c1,data_invert_flag);
c1_length = length(c1);

%% Calculating onset and R locations, their heights and respective confidence factors
[onset_pks1,onset_locs1,R_pks1,R_locs1,conf_fac1] = ComputeLocsPksAndCF(c1,c1_length,initial_param,reduced_param);

%% For plotting the individual confidence factors
R_low1 = R_locs1(find(conf_fac1 == 20));
R_good1 = R_locs1(find(conf_fac1 == 60));
R_high1 = R_locs1(find(conf_fac1 == 100));
R_low1_markers = (mean(c1)+20)*ones(1,length(R_low1));
R_good1_markers = (mean(c1)+40)*ones(1,length(R_good1));
R_high1_markers = (mean(c1)+60)*ones(1,length(R_high1));
R_locs1_markers = (mean(c1))*ones(1,length(R_locs1));


%% Manage Inverted/Non-Inverted Signal
c2 = data(:,3);
data_invert_flag = 1;
c2 = InvertSignal(c2,data_invert_flag);
c2_length = length(c2);

%% Calculating onset and R locations, their heights and respective confidence factors
[onset_pks2,onset_locs2,R_pks2,R_locs2,conf_fac2] = ComputeLocsPksAndCF(c2,c2_length,initial_param,reduced_param);

%% For plotting the individual confidence factors
R_low2 = R_locs2(find(conf_fac2 == 20));
R_good2 = R_locs2(find(conf_fac2 == 60));
R_high2 = R_locs2(find(conf_fac2 == 100));
R_low2_markers = (mean(c2)+20)*ones(1,length(R_low2));
R_good2_markers = (mean(c2)+40)*ones(1,length(R_good2));
R_high2_markers = (mean(c2)+60)*ones(1,length(R_high2));
R_locs2_markers = (mean(c2))*ones(1,length(R_locs2));



%% Calculating Confidence Factor using 2 Leads Voting
[R_locs,conf_fac_by_2leads,conf_fac_by_algo] = GetConfidenceByLeadVoteAndCombinedParams(R_locs1,R_locs2,conf_fac1,conf_fac2);


%% Re-Calculating Confidence Factor of Low Confidence R locs using RRI
[conf_fac_by_2leads,high_RRI_count] = GetConfidenceOfLowRLocsByRRI(R_locs,conf_fac_by_2leads);

% Final Confidence Factor
final_conf_fac = (conf_fac_by_2leads.*conf_fac_by_algo)/100;


%% For plotting the R loc confidence factors
final_R_high = R_locs(find(final_conf_fac >= 60));
final_R_good = R_locs(find(final_conf_fac >= 20 & final_conf_fac < 60));
final_R_low = R_locs(find(final_conf_fac < 20));
final_R_low_markers = (max(c1))*ones(1,length(final_R_low));
final_R_good_markers = (max(c1)+20)*ones(1,length(final_R_good));
final_R_high_markers = (max(c1)+40)*ones(1,length(final_R_high));

%% Calculating the algorithm confidence
algo_conf_fac = CalcConfidenceFactor(final_R_low,high_RRI_count,R_locs);

% Exporting the data to csv file
%[RRI_for_CSV,conf_fac_for_CSV] = CalcRRIForCSV(c1,R_locs,final_conf_fac);
%data_to_write = [(1:length(c1))',c1,RRI_for_CSV',conf_fac_for_CSV'];
%csvwrite('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\2. Double Lead New Algo Results\brigitte  subject 25 2 Lead.csv',data_to_write);


% Plot the obtained waveforms
figure; 
plot(c1,'color', 'b');
hold on
plot(final_R_low,final_R_low_markers,'marker','v', 'color', 'k', 'MarkerSize', 6);
hold on
plot(final_R_good,final_R_good_markers,'marker','v', 'color', 'r', 'MarkerSize', 6);
hold on
plot(final_R_high,final_R_high_markers,'marker','v', 'color', 'g', 'MarkerSize', 6);
hold on 
plot(c2,'color', 'm');
hold on
plot(R_locs1,R_locs1_markers,'marker','v', 'color', [0.1,0.1,0.1], 'MarkerSize', 4);
hold on
plot(R_locs2,R_locs2_markers,'marker','v', 'color', [0.5,0.5,0.5], 'MarkerSize', 4);

%hold on
%plot(R_low1,R_low1_markers,'marker','v',  'MarkerSize', 4);
%hold on
%plot(R_good1,R_good1_markers,'marker','v','MarkerSize', 4);
%hold on
%plot(R_high1,R_high1_markers,'marker','v','MarkerSize', 4);
%hold on
%plot(R_low2,R_low2_markers,'marker','v', 'MarkerSize', 4);
%hold on
%plot(R_good2,R_good2_markers,'marker','v','MarkerSize', 4);
%hold on
%plot(R_high2,R_high2_markers,'marker','v', 'MarkerSize', 4);

title(['R-Point Detection based QRS Detection with ', num2str(algo_conf_fac,4), '% Confidence Factor']);

