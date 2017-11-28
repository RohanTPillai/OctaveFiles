function [conf_fac_by_2leads,high_RRI_count] = GetConfidenceOfLowRLocsByRRI(R_locs,conf_fac_by_2leads)
  % Further segregating Confidence Factors of low R_locs based on RRI
  RRI = [0, abs(R_locs(1:end-1) - R_locs(2:end))];                     % Calculating RRIs
  low_conf_locs = find(conf_fac_by_2leads == 50);                      % Finding all locs with 50% confidence
  high_RRI_count = 0;
%  R_conf_fac_by_2leads_30 = [];
%  R_conf_fac_by_2leads_70 = [];
%  RRI_meds = zeros(1,length(RRI));

  for i = 1:length(low_conf_locs)                           % For all those low confidence locs
    % Debug
%      if R_locs(low_conf_locs(i)) == 61351
%        a = 0;
%      endif
    if (low_conf_locs(i)-13) <= 0                            % If a median of previous 12 RRIs is not possible
      RRI_med_range = RRI(1:low_conf_locs(i));
      RRI_med = median(RRI_med_range);                           % calculate median of all RRIs upto current index, else
    else 
      RRI_med_range = RRI(low_conf_locs(i)-13:low_conf_locs(i)-1);
      RRI_med = median(RRI_med_range);                        % calculate median of last 12 RRIs
    endif
%    RRI_meds(low_conf_locs(i)) = RRI_med;
    RRI_low = RRI_med - 15*RRI_med/100;                     % lower RRI threshold
    RRI_high = RRI_med + 15*RRI_med/100;                    % higher RRI threshold
    RRI_current = RRI(low_conf_locs(i));
    
    if RRI_current < RRI_low                                % If current RRI doesnt fall within acceptable threshold
      conf_fac_by_2leads(low_conf_locs(i)) = 30;                      % set confidence factor to 25%, else
%      R_conf_fac_by_2leads_30 = [R_conf_fac_by_2leads_30,R_locs(low_conf_locs(i))];    
    else 
      conf_fac_by_2leads(low_conf_locs(i)) = 70;                      % set confidence factor to 75%
%      R_conf_fac_by_2leads_70 = [R_conf_fac_by_2leads_70,R_locs(low_conf_locs(i))];
    endif
    
    if RRI_current > RRI_high
      high_RRI_count = high_RRI_count+1;
    endif
  endfor

endfunction