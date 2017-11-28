clc
clear all
close all


%%%%%%%%%% Windowed Peak detection Code - Purely So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% 3. An R-R interval would be contained in 600 ms

data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\G_B.csv');
c = data(:,2);
init_win_size = 600;                                                       % Assumed window size based on observed duration of an R-R interval *****NOT GIVEN IN SO & CHAN*****
num_of_windows = floor(length(c)/init_win_size);
last_win_size = mod(length(c),init_win_size);
R_pks = zeros(1,num_of_windows);
R_locs = zeros(1,num_of_windows);
onset_pks = zeros(1,num_of_windows);
onset_locs = zeros(1,num_of_windows);
win_markers = 1:init_win_size:length(c);
win_zeros = zeros(1,length(win_markers));

j = 0;
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

  maxi1 = max(slope_win1(1:end));                                            % Taking initial maxi = max slope of first 200 slope_win1 points
  parameter = 10;
  slope_threshold1 = parameter/16*maxi1;

  for i = 1:length(slope_win1)
    if (slope_win1(i)) > slope_threshold1
      onset_loc = i;
      break;
    end
  end

  onset_ht = win1(onset_loc);
  onset_pks(j+1) = onset_ht;
  onset_locs(j+1) = j*init_win_size + onset_loc;
  
  if (onset_loc+120 < length(win1))
    temp = win1(onset_loc:onset_loc+120);
  else
    temp = win1(onset_loc:end);
  end
  [R_ht, R_loc_rel] = max(temp);
  R_loc_abs = onset_loc+R_loc_rel;
  R_pks(j+1) = R_ht;
  R_locs(j+1) = j*init_win_size + R_loc_abs;
  j=j+1;  
end


% Calculation of R-R intervals
RRI = abs(R_locs(1:end-1) - R_locs(2:end));
RRI_range = range(RRI);
RRI_std = std(RRI);
RRI_var = var(RRI);
RRI_max = max(RRI);
RRI_min = min(RRI);

% Plots of obtained waveforms
figure; plot(c);
hold on
plot(onset_locs,onset_pks,'marker','v','color', 'r', 'MarkerSize', 6);
hold on
plot(R_locs,R_pks,'marker','v','color', 'g', 'MarkerSize', 6);
hold on
plot(win_markers,win_zeros,'marker','v','color', 'k', 'MarkerSize', 6);
title('Original Data');


%figure; plot(slope_win1);
%title('Original Data Slope');

figure;plot(RRI);
title('RRI');