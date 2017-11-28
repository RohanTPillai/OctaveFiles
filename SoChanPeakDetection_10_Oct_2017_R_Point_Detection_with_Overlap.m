%%%%%%%%%% Windowed Peak detection Code - Purely So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% 3. An R-R interval would be contained in 900 ms
% Edits 
% Implementation of So and Chan (R-point detection method) with no tweaks



%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Jayesh Acharya.csv');
%c = data(:,2);
%c = c + abs(min(c));


data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Acharyas\Jitendra_Acharya 1.csv');
c = -data(:,3);
c = c - min(c);


% RRI Ground truth from Chronovisor CSV File
RRI_true_val = data(:,5);
RRI_true_val_locs = find(RRI_true_val ~= 0);
RRI_true_val = RRI_true_val(RRI_true_val ~= 0);

init_win_size = 900;                                                            % Assumed window size based on observed duration of an R-R interval *****NOT GIVEN IN SO & CHAN*****
overlap_perc = 10;
hop_size = floor(init_win_size - init_win_size*overlap_perc/100);   
win_start_array = 1:hop_size:length(c);
                                              
num_of_windows = ceil(length(c)/hop_size);
last_win_size = mod(length(c),init_win_size);
R_pks = zeros(1,num_of_windows);
R_locs = zeros(1,num_of_windows);
onset_pks = zeros(1,num_of_windows);
onset_locs = zeros(1,num_of_windows);
win_markers_start = 1:hop_size:length(c);
win_markers_end = win_markers_start + init_win_size;
win_zeros = mean(c)*ones(1,length(win_markers_start));
missed_win_locs = zeros(1,num_of_windows);
slope_thresholds = zeros(1,num_of_windows);
slope = zeros(1,length(c));

j = 0;
k = 0;
if init_win_size < length(c)
  continue_iteration = 1;
else 
  continue_iteration = 0;
end

while (continue_iteration == 1 && length(c(j*hop_size+1:end)) > 5)
  if ((j+1)*hop_size <= length(c))
    win1 = c(j*hop_size+1:j*hop_size + init_win_size);
    continue_iteration = 1;
  else
    win1 = c(j*hop_size+1:end);    
    continue_iteration = 0;
  end   
  
  slope_win1 = zeros(1,length(win1));
  for i = 3:length(win1)-2
      slope_win1(i) = (-2*win1(i-2) - win1(i-1) + win1(i+1) + 2*win1(i+2));    % Slope calculation of the window points
  end 
  
  if ((j+1)*hop_size <= length(c))
    slope(j*hop_size+1:j*hop_size + init_win_size) = slope_win1; 
  else
    slope(j*hop_size+1:end) = slope_win1; 
  end
  
  if j == 0
    maxi1 = max(slope_win1(1:200));                                            % Taking initial maxi = max slope of first 200 slope_win1 points  
  end
     
  
  parameter = 10;
  slope_threshold1 = parameter/16*maxi1;
  slope_thresholds(j+1) = slope_threshold1;

  onset_loc = find(slope_win1 > slope_threshold1);
  if ~isempty(onset_loc)
    onset_loc = onset_loc(1);
    onset_ht = win1(onset_loc);
    
    if (onset_loc+120 < length(win1))
      temp = win1(onset_loc+1:onset_loc+120);
    else
      temp = win1(onset_loc+1:end);
    end
    
%    temp = win1(onset_loc+1:end);
    
    [R_ht, R_loc_rel] = max(temp);
    R_loc_abs = onset_loc+R_loc_rel;
  
  % maxi calculation based on R-point detection method
    filter_param = 16;
    maxi1 = (((R_ht - onset_ht) - maxi1)/filter_param) + maxi1;
        
    onset_pks(j+1) = onset_ht;
    onset_locs(j+1) = j*hop_size + onset_loc;
    R_pks(j+1) = R_ht;
    R_locs(j+1) = j*hop_size + R_loc_abs;
  %  else
  %    [~,onset_loc] = max(slope_win1);
  else
    k = k + 1;    
    missed_win_locs(j+1) = j*hop_size + init_win_size/2;
  end  
  j=j+1;  
end

win_zeros1 = mean(slope)*ones(1,length(win_markers_start));
non_empty_onset_locs = find(onset_locs ~= 0);
onset_pks = onset_pks(non_empty_onset_locs);
onset_locs = onset_locs(non_empty_onset_locs);
R_pks = R_pks(non_empty_onset_locs);
R_locs = R_locs(non_empty_onset_locs);
missed_win_locs = missed_win_locs(missed_win_locs ~= 0);
missed_win_markers = mean(c)*ones(1,length(missed_win_locs));

% Calculation of R-R intervals
R_locs_unique = unique(R_locs);
RRI = [0, abs(R_locs_unique(1:end-1) - R_locs_unique(2:end))];
RRI_locs = find(RRI > 5);
R_locs_unique = R_locs_unique(RRI_locs);
RRI = RRI(RRI_locs);
RRI_mode = mode(RRI);
RRI_ectopic1 = find((RRI < 700 & RRI > 100));
RRI_ectopic2 = find((RRI > 1400 & RRI < 2000));
RRI_ectopic = R_locs_unique([RRI_ectopic1 RRI_ectopic2]);
RRI_ectopic_markers = (max(c)+10)*ones(1,length(RRI_ectopic));
RRI_artifact1 = find(RRI < 100);
RRI_artifact2 = find(RRI > 2000); 
RRI_artifact = R_locs_unique([RRI_artifact1 RRI_artifact2]);
RRI_artifact_markers = (max(c)+50)*ones(1,length(RRI_artifact)); 


% Calculation of actual RRI artifacts and ectopic values obtained from the csv file
RRI_true_val = RRI_true_val';
RRI_true_val_locs = RRI_true_val_locs';
RRI_true_val_ectopic1 = find((RRI_true_val < 700 & RRI_true_val > 100));
RRI_true_val_ectopic2 = find((RRI_true_val > 1400 & RRI_true_val < 2000));
RRI_true_val_ectopic = RRI_true_val_locs([RRI_true_val_ectopic1 RRI_true_val_ectopic2]);
RRI_true_val_ectopic_markers = (max(RRI_true_val)+10)*ones(1,length(RRI_true_val_ectopic));
RRI_true_val_artifact1 = find(RRI_true_val < 100);
RRI_true_val_artifact2 = find(RRI_true_val > 2000); 
RRI_true_val_artifact = RRI_true_val_locs([RRI_true_val_artifact1 RRI_true_val_artifact2]);
RRI_true_val_artifact_markers = (max(RRI_true_val)+50)*ones(1,length(RRI_true_val_artifact)); 


win_markers1 = win_markers_start + init_win_size/2;

% Plots of obtained waveforms
figure; 
plot(c);
hold on
plot(onset_locs,onset_pks,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(R_locs,R_pks,'marker','v', 'color', 'g', 'MarkerSize', 6);
hold on
plot(win_markers_start,win_zeros,'marker','v','color', 'k', 'MarkerSize', 6);
hold on
plot(win_markers_end,win_zeros,'marker','v','color', 'c', 'MarkerSize', 6);
hold on
plot(missed_win_locs,missed_win_markers,'marker','v','color', 'm', 'MarkerSize', 6);
hold on
plot(slope);
hold on
plot(win_markers1,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);
hold on
plot(RRI_artifact, RRI_artifact_markers,'marker','v', 'MarkerSize', 6);
hold on
plot(RRI_ectopic, RRI_ectopic_markers,'marker','v','MarkerSize', 6);
title('R-Point Detection based QRS Detection with Overlap');


%subplot(212)
%plot(slope);
%hold on
%plot(win_markers1,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);
%hold on
%plot(win_markers,win_zeros1,'marker','v','color', 'k', 'MarkerSize', 6);

RRI_ectopic_markers = (max(RRI)+10)*ones(1,length(RRI_ectopic));
RRI_artifact_markers = (max(RRI)+50)*ones(1,length(RRI_artifact)); 

figure;plot(R_locs_unique,RRI,'marker','v','color', 'b', 'MarkerSize', 6);
hold on
plot(RRI_artifact, RRI_artifact_markers,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(RRI_ectopic, RRI_ectopic_markers,'marker','v','color', 'g','MarkerSize', 6);
title('R-Point Detection based RRI');

figure;plot(RRI_true_val_locs,RRI_true_val,'marker','v','color', 'b', 'MarkerSize', 6);
hold on
plot(RRI_true_val_artifact, RRI_true_val_artifact_markers,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(RRI_true_val_ectopic, RRI_true_val_ectopic_markers,'marker','v','color', 'g','MarkerSize', 6);
title('RRI Ground Truth');

figure;plot(R_locs_unique,RRI,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(RRI_true_val_locs,RRI_true_val,'marker','v','color', 'b', 'MarkerSize', 6);
title('RRI Comparision');