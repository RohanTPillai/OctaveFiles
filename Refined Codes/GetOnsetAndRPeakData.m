function [onset_pk,onset_loc,R_pk,R_loc_abs] = GetOnsetAndRPeakData(c,c_length,i)
  % Calculating QRS onset location and height
  onset_loc = i;
  onset_pk = c(onset_loc);
  
  % Setting a window for finding R peak after the detected QRS onset
  if (onset_loc+120 < c_length)
    temp = c(onset_loc+1:onset_loc+120);
  else
    temp = c(onset_loc+1:end);
  endif
  
  % Calculating R location and height
  [R_pk, R_loc_rel] = max(temp);
  R_loc_abs = onset_loc+R_loc_rel;
endfunction