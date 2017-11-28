function [i_new_val,retrig_delay] = CalcRetriggerDelay(R_loc,RRI,RRI_med)
  if isempty(RRI)                                                 % When there are no peaks detected yet
    retrig_delay = 400;
    i_new_val = R_loc + 400;                                  % Set fixed delay
  else     
    retrig_delay = ceil(0.6*RRI_med);
    i_new_val = R_loc + ceil(0.6*RRI_med);                    % Set delay based on half of RRI median 
  endif
endfunction