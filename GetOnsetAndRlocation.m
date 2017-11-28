function [onset_ht, onset_loc, R_ht, R_loc_abs] = GetOnsetAndRlocation(maxi1,win1,slope_win1)
  parameter = 10;
  slope_threshold1 = parameter/16*maxi1;

%  for i = 1:length(slope_win1)
%    if (slope_win1(i)) > slope_threshold1
%      onset_loc = i;
%      break;
%    else
%      [~,onset_loc] = max(slope_win1);
%    end
%  end
  
  onset_loc = slope_win1(slope_win1 > slope_threshold1);
  if ~isempty(onset_loc)
    onset_loc = onset_loc(1);
  else
    [~,onset_loc] = max(slope_win1);
  end

  onset_ht = win1(onset_loc);
    
%  if (onset_loc+120 < length(win1))
%    temp = win1(onset_loc:onset_loc+120);
%  else
%    temp = win1(onset_loc:end);
%  end

  temp = win1(onset_loc:end);
  
  [R_ht, R_loc_rel] = max(temp);
  R_loc_abs = onset_loc+R_loc_rel;
endfunction