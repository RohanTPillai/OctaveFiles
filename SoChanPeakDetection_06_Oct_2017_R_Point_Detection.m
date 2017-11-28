%%%%%%%%%% Windowed Peak detection Code - Purely So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% 3. An R-R interval would be contained in 900 ms
% Edits 
% Implementation of So and Chan (R-point detection method) with no tweaks



%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Dagmar_Reibhauer.csv');
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\christine  23 kmoch.csv');
c = -data(:,2);
c = c - min(c);

%c = data(:,2);
%c = c + abs(min(c));

% RRI Ground truth from Chronovisor CSV File
%RRI_true_val = data(:,4);
%RRI_true_val = RRI_true_val(RRI_true_val ~= 0 & RRI_true_val >= 600);

init_win_size = 900;                                                            % Assumed window size based on observed duration of an R-R interval *****NOT GIVEN IN SO & CHAN*****                                             
num_of_windows = floor(length(c)/init_win_size);
last_win_size = mod(length(c),init_win_size);
R_pks = zeros(1,num_of_windows);
R_locs = zeros(1,num_of_windows);
onset_pks = zeros(1,num_of_windows);
onset_locs = zeros(1,num_of_windows);
win_markers = 1:init_win_size:length(c);
win_zeros = mean(c)*ones(1,length(win_markers));
missed_win_locs = zeros(1,num_of_windows);
slope_thresholds = zeros(1,num_of_windows);
slope = [];

j = 0;
k = 0;
if init_win_size < length(c)
  continue_iteration = 1;
else 
  continue_iteration = 0;
end

while (continue_iteration == 1 && length(c(j*init_win_size+1:end)) > 5)
  if ((j+1)*init_win_size <= length(c))
    win1 = c(j*init_win_size+1:(j+1)*init_win_size);
    continue_iteration = 1;
  else
    win1 = c(j*init_win_size+1:end);    
    continue_iteration = 0;
  end   
  
  slope_win1 = zeros(1,length(win1));
  for i = 3:length(win1)-2
      slope_win1(i) = -2*win1(i-2) - win1(i-1) + win1(i+1) + 2*win1(i+2);    % Slope calculation of the window points
  end 
  slope = [slope slope_win1]; 
  
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
    onset_locs(j+1) = j*init_win_size + onset_loc;
    R_pks(j+1) = R_ht;
    R_locs(j+1) = j*init_win_size + R_loc_abs;
  %  else
  %    [~,onset_loc] = max(slope_win1);
  else
    k = k + 1;    
    missed_win_locs(j+1) = j*init_win_size + init_win_size/2;
  end  
  j=j+1;  
end

win_zeros1 = mean(slope)*ones(1,length(win_markers));
non_empty_onset_locs = find(onset_locs ~= 0);
onset_pks = onset_pks(non_empty_onset_locs);
onset_locs = onset_locs(non_empty_onset_locs);
R_pks = R_pks(non_empty_onset_locs);
R_locs = R_locs(non_empty_onset_locs);
missed_win_locs = missed_win_locs(missed_win_locs ~= 0);
missed_win_markers = mean(c)*ones(1,length(missed_win_locs));

% Calculation of R-R intervals
RRI = [0, abs(R_locs(1:end-1) - R_locs(2:end))];

win_markers1 = win_markers + init_win_size/2;

% Plots of obtained waveforms
figure; 
plot(c);
hold on
plot(onset_locs,onset_pks,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(R_locs,R_pks,'marker','v','color', 'g', 'MarkerSize', 6);
hold on
plot(win_markers,win_zeros,'marker','v','color', 'k', 'MarkerSize', 6);
hold on
plot(missed_win_locs,missed_win_markers,'marker','v','color', 'm', 'MarkerSize', 6);
hold on
plot(slope);
hold on
plot(win_markers1,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);
title('R-Point Detection based QRS Detection');


%subplot(212)
%plot(slope);
%hold on
%plot(win_markers1,slope_thresholds,'marker','v','color', 'y', 'MarkerSize', 6);
%hold on
%plot(win_markers,win_zeros1,'marker','v','color', 'k', 'MarkerSize', 6);



%figure;plot(RRI);
%title('R-Point Detection based RRI');

%figure;plot(RRI_true_val);
%title('RRI Ground Truth');

