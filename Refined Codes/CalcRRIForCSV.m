function[RRI_for_CSV,conf_fac_for_CSV] = CalcRRIForCSV(c,R_locs,final_conf_fac)
  RRI_for_CSV = zeros(1,length(c));
  conf_fac_for_CSV = zeros(1,length(c));
  RRI = [0,abs(R_locs(1:end-1) - R_locs(2:end))];      
  for i = 1:length(R_locs)
    RRI_for_CSV(R_locs(i)) = RRI(i);
    conf_fac_for_CSV(R_locs(i)) = final_conf_fac(i);
  endfor
  RRI_for_CSV(RRI_for_CSV == 0) = NaN;
  conf_fac_for_CSV(conf_fac_for_CSV == 0) = NaN;
endfunction