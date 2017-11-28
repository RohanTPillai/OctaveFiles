%%%%%%%%%% Windowed Peak detection Code - Purely So and Chan method, with intuitive inputs 
% Development started on 03rd Oct 2017 by Rohan Pillai
% Assumptions:
% 1. Sampling rate = 1000Hz
% 2. max QRS interval > 120 ms, i.e., 120 samples
% Edits 
% Adaptive trigger implementation has been incorporated to the existing No windows algorithm

%clear all

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
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika dogpose.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika paschimotanasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika resting.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika sarvangasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shavasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika shisasana.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika tadasan.csv');
%data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\German Recordings\Monika\Exported Report\monika virbhadrasana I.csv');


% Non-inverted signal
c = data(:,3);
c = c + abs(min(c));

% Inverted signal
%c = -data(:,2);
%c = c - min(c);


% RRI Ground truth from Chronovisor CSV File
RRI_true_val = data(:,3);
RRI_true_val_locs = find(RRI_true_val ~= 0);
RRI_true_val = RRI_true_val(RRI_true_val ~= 0);

% Param initialization
c_length = length(c);
R_pks = zeros(1,c_length);
R_locs = zeros(1,c_length);
RRI = [];
RRI_meds = zeros(1,c_length);
onset_pks = zeros(1,c_length);
onset_locs = zeros(1,c_length);
slope_thresholds = zeros(1,c_length);
maxis = zeros(1,c_length);
no_of_peaks = 12;
conf_fac_by_slope = [];
conf_fac_by_RRI = [];
R_high = [];
R_low = [];

j = 0;      % Slope overload iterator
parameter = 10;
filter_param = 16;

% Slope calculation
slope = zeros(1,c_length);
  for i = 3:c_length-2
      slope(i) = (-2*c(i-2) - c(i-1) + c(i+1) + 2*c(i+2));    % Slope calculation of the signal      
  endfor
  

% Setting Initial maxi value
maxi = max(slope(1:1000));
i = 1;

% Iterating through the signal
while(i < c_length)
  expected_RS_sig = [];
  scanning_RS_sig = [];

  % Calculating slope threshold  
  slope_threshold = parameter/16*maxi;
  
  % Checking the slope condition for all slope values
  if (slope(i) > slope_threshold && slope(i+1) > slope_threshold)
    
    j = 0;
    % Calculating QRS onset location and height
    onset_loc = i;
    onset_pk = c(onset_loc);
    
    % Setting a window for finding R peak after the detected QRS onset
    if (onset_loc+120 < length(c))
      temp = c(onset_loc+1:onset_loc+120);
    else
      temp = c(onset_loc+1:end);
    endif
    
    % Calculating R location and height
    [R_pk, R_loc_rel] = max(temp);
    R_loc_abs = onset_loc+R_loc_rel;
    
% debug
%    if R_loc_abs == 28928
%      a = 0;
%    endif
    
    % Updating maxi        
    maxi = (((R_pk - onset_pk) - maxi)/filter_param) + maxi;
    
    % Keep track of all pks and onsets and slope threshold
    onset_pks(i) = onset_pk;
    onset_locs(i) = onset_loc;      
    R_pks(i) = R_pk;    
    R_locs(i) = R_loc_abs;
    slope_thresholds(i) = slope_threshold;
    maxis(i) = maxi;
    
    % Computing RRIs
    if length(R_locs(R_locs~=0)) > 1
      R_locs_non_zero = R_locs(R_locs~=0);
      if length(R_locs_non_zero) <= no_of_peaks
        RRI = [0, abs(R_locs_non_zero(1:end-2) - R_locs_non_zero(2:end-1))];
      else
        RRI = [0, abs(R_locs_non_zero(end-no_of_peaks:end-2) - R_locs_non_zero(end-no_of_peaks+1:end-1))];
      endif
    endif
%    RRI_non_neg = RRI(RRI >= 0);                                   % Eliminating Non-negative RRI values created during initialization
    
    if isempty(RRI)                                                 % When there are no peaks detected yet
      i_new_val = R_loc_abs + 400;                                  % Set fixed delay
    else 
      RRI_med = median(RRI);   
      RRI_meds(i) = RRI_med;
      i_new_val = R_loc_abs + ceil(0.6*RRI_med);                    % Set delay based on half of RRI median 
    endif
    
    %% Implementing confidence factor using RRIs
    if ~isempty(RRI)
      RRI_low = RRI_med - 15*RRI_med/100;                     % lower RRI threshold
      RRI_high = RRI_med + 15*RRI_med/100;                    % higher RRI threshold
      RRI_current = abs(R_locs_non_zero(end)-R_locs_non_zero(end-1));
      
      % If current RRI is lesser than lower RRI median threshold 
      if RRI_current < RRI_low
        conf_fac_by_RRI = [conf_fac_by_RRI,10];
      else
        conf_fac_by_RRI = [conf_fac_by_RRI,50];
      endif
    else 
        conf_fac_by_RRI = [conf_fac_by_RRI,10];
    endif
  
    
    %% Implementing confidence factor using negative slope of the RS interval
    RS_sig_range = R_loc_abs + 60;        
    
    % debug
%    if R_loc_abs == 23832
%      s = 0;
%    endif
    
    if i_new_val >  RS_sig_range                                           % If testing range for false positives is greater than expected RS interval      
      if c_length >= i_new_val                                             % If remaining signal length is greater than testing range
        expected_RS_sig = slope(R_loc_abs+1:RS_sig_range);                     % Ideal RS interval
        scanning_RS_sig = slope(RS_sig_range+1:i_new_val);                        % Signal Range to check for false positives          
      elseif c_length < i_new_val && c_length > RS_sig_range               % If remaining signal length is less than testing range but greater than RS interval
        expected_RS_sig = slope(R_loc_abs+1:RS_sig_range);                     % Ideal RS interval
        scanning_RS_sig = slope(RS_sig_range+1:c_length);                         % Signal Range to check for false positives
      elseif c_length < RS_sig_range                                       % If remaining signal length is less than RS interval
        conf_fac_by_slope = [conf_fac_by_slope,50];                                         % No comparison possible, R pk is awarded 100% confidence
        R_high = [R_high,R_loc_abs];
      endif
    else 
      conf_fac_by_slope = [conf_fac_by_slope,50];                                           % No comparison possible, R pk is awarded 100% confidence
      R_high = [R_high,R_loc_abs];
    endif
    
    % If the minima corresponding to expected RS interval is greater than minima of the test range,       
    % that R loc is given 50% confidence
    if ~isempty(expected_RS_sig) && ~isempty(scanning_RS_sig)
      expected_RS_sig_min = min(expected_RS_sig);
      scanning_RS_sig_min = min(scanning_RS_sig);
      if expected_RS_sig_min > scanning_RS_sig_min
        conf_fac_by_slope = [conf_fac_by_slope,10];
        R_low = [R_low,R_loc_abs];
      else
        conf_fac_by_slope = [conf_fac_by_slope,50];
        R_high = [R_high,R_loc_abs];
      end
    end
    
    
    % Re-trigger Delay
    if i_new_val < c_length                                        % Checking if the updated index is within bounds
      i = i_new_val;
    else 
      i = c_length;
    endif  
    
  else
    % If slope overload occurs (i.e. case in which slope_threshold is always greater 
    % than slope for a many successive of R peaks), maxi is reset to max of 200 slope point after i
    j = j+1;    
    if (j > 5000)
      if i+1000 < c_length
        maxi = max(slope(i:i+1000));
      else
        maxi = max(slope(i:end));
      j = 0;
      endif
    endif
    i = i + 1;  
  endif
  
endwhile


% Selecting pks and onsets based on non-zero onset_locs only, as it would contain zeros 
% due to periodic i-update in the for loop above
non_empty_onset_locs = find(onset_locs ~= 0);
onset_pks = onset_pks(non_empty_onset_locs);
onset_locs = onset_locs(non_empty_onset_locs);
R_pks = R_pks(non_empty_onset_locs);
R_locs = R_locs(non_empty_onset_locs);
slope_thresholds = slope_thresholds(non_empty_onset_locs);
maxis = maxis(non_empty_onset_locs);
RRI_meds = RRI_meds(non_empty_onset_locs);

% Plotting the confidence factors
R_high_markers = (max(c)+40)*ones(1,length(R_high));
R_low_markers = (max(c)+20)*ones(1,length(R_low));
final_conf_fac = conf_fac_by_slope+conf_fac_by_RRI;
final_R_low = R_locs(find(final_conf_fac == 20));
final_R_good = R_locs(find(final_conf_fac == 60));
final_R_high = R_locs(find(final_conf_fac == 100));
final_R_low_markers = (max(c))*ones(1,length(final_R_low));
final_R_good_markers = (max(c)+20)*ones(1,length(final_R_good));
final_R_high_markers = (max(c)+40)*ones(1,length(final_R_high));

% Confidence Factor calculation for new algorithm
%RRI_mean = mean(RRI);
%RRI_SD = 15*(RRI_mean)/100;
%RRI_incorrect = length(RRI(RRI >= (RRI_mean + RRI_SD) | RRI <= (RRI_mean - RRI_SD)));
%Conf_fac = (length(RRI) - RRI_incorrect)/length(RRI)*100;

% Confidence Factor calculation for existing Chronovisor algorithm
%RRI_true_mean = mean(RRI_true_val);
%RRI_true_SD = 15*(RRI_true_mean)/100;
%RRI_true_incorrect = length(RRI_true_val(RRI_true_val >= (RRI_true_mean + RRI_true_SD) | RRI_true_val <= (RRI_true_mean - RRI_true_SD)));
%Conf_fac_ex = (length(RRI_true_val) - RRI_true_incorrect)/length(RRI_true_val)*100;


% Calculation of RRI and its artifact and ectopic values
RRI = [0, abs(R_locs(1:end-1) - R_locs(2:end))];
RRI_mode = mode(RRI);
RRI_ectopic1 = find((RRI < 700 & RRI > 100));
RRI_ectopic2 = find((RRI > 1400 & RRI < 2000));
RRI_ectopic = R_locs([RRI_ectopic1 RRI_ectopic2]);
RRI_ectopic_markers = (max(c)+10)*ones(1,length(RRI_ectopic));
RRI_artifact1 = find(RRI < 100);
RRI_artifact2 = find(RRI > 2000); 
RRI_artifact = R_locs([RRI_artifact1 RRI_artifact2]);
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

figure;
plot(c);
hold on
plot(R_locs,R_pks,'marker','v', 'color', 'g', 'MarkerSize', 6);
hold on
plot(final_R_high,final_R_high_markers,'marker','v', 'color', 'r', 'MarkerSize', 4);
hold on
plot(final_R_good,final_R_good_markers,'marker','v', 'color', 'c', 'MarkerSize', 4);
hold on
plot(final_R_low,final_R_low_markers,'marker','v', 'color', 'k', 'MarkerSize', 4);
hold on
plot(slope);

