function [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R_loc_value,lead_conf_value,algo_conf_value,i,k,inc_case)
  R_locs = [R_locs,R_loc_value];        
  conf_fac_by_2leads = [conf_fac_by_2leads,lead_conf_value];
  conf_fac_by_algo = [conf_fac_by_algo,algo_conf_value];
  if inc_case == 1
    i = i+1;
    k = k+1;
  elseif inc_case == 2
    i = i+1;
  elseif inc_case == 3
    k = k+1;
  endif
endfunction