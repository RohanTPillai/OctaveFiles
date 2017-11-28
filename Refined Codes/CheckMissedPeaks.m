function [i,j,parameter,missed_pk_no] = CheckMissedPeaks(i,j,c_length,retrig_delay,i_new_val,Rlocs_length,parameter,missed_pk_no,reduced_param)    
  if j > 1.5*retrig_delay && Rlocs_length > 12 && missed_pk_no ~=0  
    i = i_new_val;
    parameter = reduced_param;
    missed_pk_no = 0;
    j = 0;    
  else
    i = i+1;
    parameter = parameter;
    missed_pk_no = missed_pk_no;
    j = j+1;     
  endif
endfunction