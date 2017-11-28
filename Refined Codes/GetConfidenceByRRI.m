function [conf_fac_by_RRI,high_RRI_count] = GetConfidenceByRRI(conf_fac_by_RRI,RRI,RRI_med,R_locs,high_RRI_count)
  if ~isempty(RRI)
    RRI_low = RRI_med - 15*RRI_med/100;                     % lower RRI threshold
    RRI_high = RRI_med + 15*RRI_med/100;                    % higher RRI threshold
    RRI_current = abs(R_locs(end)-R_locs(end-1));
    
    % If current RRI is lesser than lower RRI median threshold, corresponding R_loc is given low confidence
    if RRI_current < RRI_low
      conf_fac_by_RRI = [conf_fac_by_RRI,10];
    else
      conf_fac_by_RRI = [conf_fac_by_RRI,50];
    endif
    
    if RRI_current > RRI_high
      high_RRI_count = high_RRI_count+1;
    endif
  else 
      conf_fac_by_RRI = [conf_fac_by_RRI,10];               % When R_locs has only one value, RRI calculation is not possible. That R_loc is given low confidence
  endif
endfunction