function conf_fac_by_slope = GetConfidenceBySlope(slope,c_length,i_new_val,R_loc)
  %% Implementing confidence factor using negative slope of the RS interval
  expected_RS_sig = [];
  scanning_RS_sig = [];
  RS_sig_range = R_loc + 60;           
  if i_new_val >  RS_sig_range                                           % If testing range for false positives is greater than expected RS interval      
    if c_length >= i_new_val                                             % If remaining signal length is greater than testing range
      expected_RS_sig = slope(R_loc+1:RS_sig_range);                     % Ideal RS interval
      scanning_RS_sig = slope(RS_sig_range+1:i_new_val);                 % Signal Range to check for false positives          
    elseif c_length < i_new_val && c_length > RS_sig_range               % If remaining signal length is less than testing range but greater than RS interval
      expected_RS_sig = slope(R_loc+1:RS_sig_range);                     % Ideal RS interval
      scanning_RS_sig = slope(RS_sig_range+1:c_length);                  % Signal Range to check for false positives
    elseif c_length < RS_sig_range                                       % If remaining signal length is less than RS interval
      conf_fac_by_slope = 10;                        % No comparison possible, R pk is awarded low confidence      
    endif
  else 
    conf_fac_by_slope = 10;                          % No comparison possible, R pk is awarded low confidence    
  endif
  
  % If the minima corresponding to expected RS interval is greater than minima of the test range,       
  % that R loc is given low confidence, else high confidence
  if ~isempty(expected_RS_sig) && ~isempty(scanning_RS_sig)
    expected_RS_sig_min = min(expected_RS_sig);
    scanning_RS_sig_min = min(scanning_RS_sig);
    if expected_RS_sig_min > scanning_RS_sig_min
      conf_fac_by_slope = 10;      
    else
      conf_fac_by_slope = 50;    
    end
  end
endfunction