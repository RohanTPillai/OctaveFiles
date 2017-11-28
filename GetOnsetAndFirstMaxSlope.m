function [onset_ht, onset_loc, first_max_slope, R_ht, R_loc_abs] = GetOnsetAndFirstMaxSlope(maxi1,win1,slope_win1)
  parameter = 10;
  slope_threshold1 = parameter/16*maxi1;
  
  onset_loc = slope_win1(slope_win1 > slope_threshold1);
  if ~isempty(onset_loc)
    onset_loc = onset_loc(1);
  else
    [~,onset_loc] = max(slope_win1);
  end

  onset_ht = win1(onset_loc);
    
  temp = slope_win1(onset_loc:end);
  
  [max_slps, R_locs] = findpeaks(temp,"DoubleSided");
  R_loc_rel = R_locs(1);
  first_max_slope = max_slps(1);
  R_loc_abs = onset_loc+R_loc_rel;
  R_ht = win1(R_loc_abs);
endfunction