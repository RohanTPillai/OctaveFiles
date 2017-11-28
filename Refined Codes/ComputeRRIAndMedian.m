function [RRI,RRI_med] = ComputeRRIAndMedian(R_locs,no_of_peaks)
  % Computing RRIs
  if length(R_locs) > 2    
    if length(R_locs) <= no_of_peaks
      RRI = [0,abs(R_locs(1:end-2) - R_locs(2:end-1))];      
    else
      RRI = [abs(R_locs(end-no_of_peaks:end-2) - R_locs(end-no_of_peaks+1:end-1))];
    endif
    RRI_med = median(RRI);
  else
    RRI = [];
    RRI_med = [];
  endif  
endfunction