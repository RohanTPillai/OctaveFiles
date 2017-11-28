%%%%%%%%%% Windowed Peak detection Code - Based on So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% Edits 
% 2-lead ECG Peak detection (Best of both) has been incorporated using the existing Adaptive Trigger - No windows algorithm


clear all
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Dagmar_1.csv');
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
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Leena Phadke\LEENA_PHADKE.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika dogpose.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika paschimotanasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika resting.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika sarvangasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shavasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shisasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika tadasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika virbhadrasana I.csv');

% RRI Ground truth from Chronovisor CSV File
%RRI_true_val = data(:,5);
%RRI_true_val_locs = find(RRI_true_val ~= 0);
%RRI_true_val = RRI_true_val(RRI_true_val ~= 0);

%% Signal 1

% Non-inverted signal
c1 = data(:,2);
c1 = c1 + abs(min(c1));

% Inverted signal
%c1 = -data(:,2);
%c1 = c1 - min(c1);

[R_pks1,R_locs1,R_low1,R_good1,R_high1,conf_fac1] = Func_SoChanPeakDetection_R_Point_Detection_with_Overlap_No_Windows_Adaptive_Trigger_Conf_Fac(c1);

%RRI1 = [0, abs(R_locs1(1:end-1) - R_locs1(2:end))];


%% Signal 2

% Non-inverted signal
c2 = data(:,3);
c2 = c2 + abs(min(c2));

% Inverted signal
%c2 = -data(:,3);
%c2 = c2 - min(c2);

[R_pks2,R_locs2,R_low2,R_good2,R_high2,conf_fac2] = Func_SoChanPeakDetection_R_Point_Detection_with_Overlap_No_Windows_Adaptive_Trigger_Conf_Fac(c2);


% Initialization factors
i = 1;
k = 1;
R_locs = [];
R1_high = [];
R1_low = [];
R2_low = [];
conf_fac_by_2leads = [];
conf_fac_by_algo = [];

%% Calculating Peak Detection Confidence using Lead Voting 
while(i <= length(R_locs1))
  if R_locs1(i) == 150730
    a = 0;
  endif
  R1value = R_locs1(i);
  while(k <= length(R_locs2))
    R2value = R_locs2(k);   
    if abs(R1value - R2value) <= 5                     % Match is found, choosing R1 with 100% confidence
      R_locs = [R_locs,R1value];
      R1_high = [R1_high,R1value];
      conf_fac_by_2leads = [conf_fac_by_2leads,100];
      conf_fac_by_algo = [conf_fac_by_algo,100];
      i = i+1;
      k = k+1;
      break;
    elseif (R2value > R1value)                        % R1 peak not present in R2, add R1 peak with 50% confidence
      R_locs = [R_locs,R1value];
      R1_low = [R1_low,R1value];
      conf_fac_by_2leads = [conf_fac_by_2leads,50];
      conf_fac_by_algo = [conf_fac_by_algo,conf_fac1(i)];
      i = i+1;
      break;
    elseif (R2value < R1value)                        % R2 peak not present in R1, add R2 peak with 50% confidence
      R_locs = [R_locs,R2value];
      R2_low = [R2_low,R2value];
      conf_fac_by_2leads = [conf_fac_by_2leads,50];
      conf_fac_by_algo = [conf_fac_by_algo,conf_fac2(k)];
      k = k+1;
      break;
    endif
  endwhile
  if k > length(R_locs2) && i <= length(R_locs1)
    R_locs = [R_locs,R1value];
    R1_low = [R1_low,R1value];
    conf_fac_by_2leads = [conf_fac_by_2leads,50];
    conf_fac_by_algo = [conf_fac_by_algo,conf_fac1(i)];
    i = i+1;
  endif
endwhile

% Further segregating Confidence Factors of low R_locs based on RRI
RRI = [0, abs(R_locs(1:end-1) - R_locs(2:end))];                     % Calculating RRIs
low_conf_locs = find(conf_fac_by_2leads == 50);                      % Finding all locs with 50% confidence
R_conf_fac_by_2leads_30 = [];
R_conf_fac_by_2leads_70 = [];
RRI_meds = zeros(1,length(RRI));

for i = 1:length(low_conf_locs)                           % For all those low confidence locs
  if (low_conf_locs(i)-13) <= 0                            % If a median of previous 12 RRIs is not possible
    RRI_med = median(RRI(1:low_conf_locs(i)));                           % calculate median of all RRIs upto current index, else
  else 
    RRI_med = median(RRI(low_conf_locs(i)-13:low_conf_locs(i)-1));                        % calculate median of last 12 RRIs
  endif
  RRI_meds(low_conf_locs(i)) = RRI_med;
  RRI_low = RRI_med - 15*RRI_med/100;                     % lower RRI threshold
  RRI_high = RRI_med + 15*RRI_med/100;                    % higher RRI threshold
  
  if RRI(low_conf_locs(i)) < RRI_low || RRI(low_conf_locs(i)) > RRI_high                % If current RRI doesnt fall within acceptable threshold
    conf_fac_by_2leads(low_conf_locs(i)) = 30;                      % set confidence factor to 25%, else
    R_conf_fac_by_2leads_30 = [R_conf_fac_by_2leads_30,R_locs(low_conf_locs(i))];    
  else 
    conf_fac_by_2leads(low_conf_locs(i)) = 70;                      % set confidence factor to 75%
    R_conf_fac_by_2leads_70 = [R_conf_fac_by_2leads_70,R_locs(low_conf_locs(i))];
  endif
endfor

final_conf_fac = (conf_fac_by_2leads.*conf_fac_by_algo)/100;
final_R_high = R_locs(find(final_conf_fac >= 60));
final_R_good = R_locs(find(final_conf_fac >= 20 & final_conf_fac < 60));
final_R_low = R_locs(find(final_conf_fac < 20));
final_R_low_markers = (max(c1))*ones(1,length(final_R_low));
final_R_good_markers = (max(c1)+20)*ones(1,length(final_R_good));
final_R_high_markers = (max(c1)+40)*ones(1,length(final_R_high));

    
  
%R1_high_markers = mean(c1)*ones(1,length(R1_high));
%R1_low_markers = (mean(c1)+10)*ones(1,length(R1_low));
%R2_low_markers = (mean(c1)-10)*ones(1,length(R2_low));
%R_conf_fac_by_2leads_30_markers = (mean(c2)-10)*ones(1,length(R_conf_fac_by_2leads_30));
%R_conf_fac_by_2leads_70_markers = (mean(c2)+10)*ones(1,length(R_conf_fac_by_2leads_70));
%RRI_meds_markers = (mean(c1)-20)*ones(1,length(RRI_meds));

%for i = 1:length(R_locs2)
%  if (abs(R_locs2(i) - R_locs1) <= 10)
%    R_locs2(i) = 0;
%  endif
%endfor
%
%R_locs2_unique = R_locs2(R_locs2~=0);
%R_pks2_unique = mean(c1)*ones(1,length(R_locs2_unique));

% Confidence Factor calculation for existing Chronovisor algorithm
%RRI_true_mean = mean(RRI_true_val);
%RRI_true_SD = 15*(RRI_true_mean)/100;
%RRI_true_incorrect = length(RRI_true_val(RRI_true_val >= (RRI_true_mean + RRI_true_SD) | RRI_true_val <= (RRI_true_mean - RRI_true_SD)));
%Conf_fac_ex = (length(RRI_true_val) - RRI_true_incorrect)/length(RRI_true_val)*100;

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
%plot(c1);
%hold on
%plot(R_locs1,R_pks1,'marker','v', 'color', 'g', 'MarkerSize', 4);
%hold on
%plot(R_locs2_unique,R_pks2_unique,'marker','v', 'color', 'r', 'MarkerSize', 4);
%%hold on
%%plot(c2);
%title('R-Point Detection based QRS Detection with Overlap');

%figure; 
%plot(c1);
%hold on
%plot(R1_high,R1_high_markers,'marker','v', 'color', 'k', 'MarkerSize', 6);
%hold on
%plot(R1_low,R1_low_markers,'marker','v', 'color', 'r', 'MarkerSize', 6);
%hold on
%plot(R2_low,R2_low_markers,'marker','v', 'color', 'g', 'MarkerSize', 6);
%hold on 
%plot(c2);
%hold on
%plot(R_conf_fac_by_2leads_30,R_conf_fac_by_2leads_30_markers,'marker','v', 'color', 'y', 'MarkerSize', 6);
%hold on
%plot(R_conf_fac_by_2leads_70,R_conf_fac_by_2leads_70_markers,'marker','v', 'color', 'm', 'MarkerSize', 6);
%hold on
%plot(R_locs,RRI_meds,'marker','v', 'color', 'c', 'MarkerSize', 6);
%title('R-Point Detection based QRS Detection');

figure; 
plot(c1);
hold on
plot(final_R_low,final_R_low_markers,'marker','v', 'color', 'k', 'MarkerSize', 4);
hold on
plot(final_R_good,final_R_good_markers,'marker','v', 'color', 'r', 'MarkerSize', 4);
hold on
plot(final_R_high,final_R_high_markers,'marker','v', 'color', 'g', 'MarkerSize', 4);
hold on 
plot(c2);
title('R-Point Detection based QRS Detection');
