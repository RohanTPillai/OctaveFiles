function [varargout] = ComputeLocsPksAndCF(c,c_length,initial_param,reduced_param)
  
  %% Param Initialization
  parameter = initial_param;
  retrig_delay = [];
  filter_param = 16;
  i = 1;
  missed_pk_no = -1;
  i_new_val = [];
  onset_pks = [];
  onset_locs = [];
  R_pks = [];
  R_locs = [];
  slope_thresholds = [];
  maxis = [];
  RRI_meds = [];
  j = 0;                                                                          % Slope overload iterator
  no_of_peaks = 13;                                                  % Adjustment needed to keep 'RRI_med' a median of 'no_of_peaks' values
  conf_fac_by_slope = [];
  conf_fac_by_RRI = [];
  high_RRI_count = 0;
  
  
  %% Slope Calculation
  slope = CalculateSlope(c,c_length);
  

  %% Setting Initial maxi value
  maxi = max(slope(1:1000));


  %% Iterating through the signal
  while i < c_length
    % Calculating slope threshold
    slope_threshold = parameter/16*maxi;       
    
    % Checking the slope condition for all slope values
    if (slope(i) > slope_threshold && slope(i+1) > slope_threshold)
      
      % Calculate Onset and R Peak location and their heights
      [onset_pk,onset_loc,R_pk,R_loc] = GetOnsetAndRPeakData(c,c_length,i);
      
      % Debug
%      if R_loc == 10469
%        a = 0;
%      endif
      
      if missed_pk_no == 0
        missed_pk_no = -1;        
      endif
      parameter = initial_param;
      
      % Updating maxi
      maxi = (((R_pk - onset_pk) - maxi)/filter_param) + maxi;
      
      % Keep track of all pks and onsets and other params
      onset_pks = [onset_pks,onset_pk];
      onset_locs = [onset_locs,onset_loc];
      R_pks = [R_pks,R_pk];
      R_locs = [R_locs,R_loc];
      slope_thresholds = [slope_thresholds,slope_threshold];
      maxis = [maxis,maxi];
      
      % Computing RRIs and its median
      [RRI,RRI_med] = ComputeRRIAndMedian(R_locs,no_of_peaks);
      RRI_meds = [RRI_meds,RRI_med];
            
      % Calculating Re-trigger Delay, i.e. the minimum time duration to be skipped after the selected peak instant
      [i_new_val,retrig_delay] = CalcRetriggerDelay(R_loc,RRI,RRI_med);
      
      % Calculating Peak Detection Confidence Factor using RRI for Single Lead
      [conf_fac_by_RRI,high_RRI_count] = GetConfidenceByRRI(conf_fac_by_RRI,RRI,RRI_med,R_locs,high_RRI_count); 
%      conf_fac_by_RRI = [GetConfidenceByRRI(RRI,RRI_med,R_locs)]; 
      
      % Calculating Peak Detection Confidence Factor using Negative Slope
%      conf_fac_by_slope = GetConfidenceBySlope(conf_fac_by_slope,slope,c_length,i_new_val,R_loc);
      conf_fac_by_slope = [conf_fac_by_slope,GetConfidenceBySlope(slope,c_length,i_new_val,R_loc)];
      
      % Setting new i
      if i_new_val < c_length                                        % Checking if the updated index is within bounds
        i = i_new_val;
      else 
        i = c_length;
      endif      
      j = 0;    
    else 
      % Debug
      if j > 1.5*retrig_delay
        a = 0;
      endif
%      [j,maxi] = CheckSlopeOverload(slope,i,j,c_length,maxi);     
      [i,j,parameter,missed_pk_no] = CheckMissedPeaks(i,j,c_length,retrig_delay,i_new_val,length(R_locs),parameter,missed_pk_no,reduced_param);
%      i = i+1;    
    endif
  endwhile

  % Final Confidence Factor
  final_conf_fac = conf_fac_by_slope+conf_fac_by_RRI;
  varargout{1} = onset_pks;
  varargout{2} = onset_locs;
  varargout{3} = R_pks;
  varargout{4} = R_locs;
  varargout{5} = final_conf_fac;
  varargout{6} = high_RRI_count;
  varargout{7} = slope;
  varargout{8} = slope_thresholds;
endfunction