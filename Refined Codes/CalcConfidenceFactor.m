function algo_conf_fac = CalcConfidenceFactor(final_R_low,high_RRI_count,R_locs)
  algo_conf_fac = (1 - (length(final_R_low)+high_RRI_count)/length(R_locs))*100;  
endfunction