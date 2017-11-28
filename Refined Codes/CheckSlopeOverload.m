function [j,maxi] = CheckSlopeOverload(slope,i,j,c_length,maxi)
  % If slope overload occurs (i.e. case in which slope_threshold is always greater 
  % than slope for a many successive of R peaks), maxi is reset to max of 1000 slope point after i  
  if (j > 5000)
    if i+1000 < c_length
      maxi = max(slope(i:i+1000));
    else
      maxi = max(slope(i:end));      
    endif
    j = 0;
  else
    j = j+1;  
    maxi = maxi;  
  endif
endfunction