function slope = CalculateSlope(c,c_length)
  slope = zeros(1,c_length);
  for i = 3:c_length-2
      slope(i) = (-2*c(i-2) - c(i-1) + c(i+1) + 2*c(i+2));    % Slope calculation of the signal      
  endfor
  % Handle Sudden Slope Surge values
  slope = HandleSlopeSurge(slope,c_length);
  endfunction