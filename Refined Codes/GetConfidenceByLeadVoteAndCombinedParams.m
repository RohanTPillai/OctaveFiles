function [R_locs,conf_fac_by_2leads,conf_fac_by_algo] = GetConfidenceByLeadVoteAndCombinedParams(R_locs1,R_locs2,conf_fac1,conf_fac2)
  i = 1;
  k = 1;
  R_locs = [];
  conf_fac_by_2leads = [];
  conf_fac_by_algo = [];
  %% Calculating Peak Detection Confidence using Lead Voting 
  while(i <= length(R_locs1))    
    R1value = R_locs1(i);
    while(k <= length(R_locs2))
      R2value = R_locs2(k);   
      
      % Debug
      if R2value == 61351
        a = 0;
      endif
      
      if abs(R1value - R2value) <= 300                            % If 2 peaks are very close to each other, there is a conflict, and we want to select only one of the two
        if abs(R1value - R2value) <= 5                            % Match is found, choosing R1 with 100% confidence
          [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,100,100,i,k,1);
          break;
        else                                                      
          if conf_fac1(i) > conf_fac2(k)                         % if confidence factor of loc from lead 1 is greater than lead 2
            [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,50,conf_fac1(i),i,k,1);
            break;
          elseif conf_fac1(i) < conf_fac2(k)                                                    % else
            [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R2value,50,conf_fac2(k),i,k,1);
            break;
          else
            [RRI,RRI_med] = ComputeRRIAndMedian(R_locs,12);
            if ~isempty(RRI)
              RRI_current1 = abs(R1value-R_locs(end));
              RRI_current2 = abs(R2value-R_locs(end));
              RRI_diff1 = abs(RRI_current1 - RRI_med);
              RRI_diff2 = abs(RRI_current2 - RRI_med);
              if RRI_diff1 <= RRI_diff2
                [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,50,conf_fac1(i),i,k,1);
                break;  
              else
                [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R2value,50,conf_fac2(k),i,k,1);
                break;
              endif
            else
              [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,50,conf_fac1(i),i,k,1);
              break;  
            endif
          endif
        endif
      elseif (R2value > R1value)                        % R1 peak not present in R2, add R1 peak with 50% confidence
        [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,50,conf_fac1(i),i,k,2);
       break;
      elseif (R2value < R1value)                        % R2 peak not present in R1, add R2 peak with 50% confidence
        [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R2value,50,conf_fac2(k),i,k,3);
        break;
      endif
    endwhile
    if k > length(R_locs2) && i <= length(R_locs1)
      [R_locs,conf_fac_by_2leads,conf_fac_by_algo,i,k] = UpdateParamsAndIncrementCounter(R_locs,conf_fac_by_2leads,conf_fac_by_algo,R1value,50,conf_fac1(1),i,k,2);
    endif
  endwhile
endfunction