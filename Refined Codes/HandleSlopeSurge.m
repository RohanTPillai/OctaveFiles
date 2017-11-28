function slope = HandleSlopeSurge(slope,c_length)
  max_slope_parts = [];
  for i = 1:1000:c_length
    if i+1000 < c_length
      slope_parts = slope(i:i+1000);
      max_slope_parts = [max_slope_parts,max(slope_parts)];    
    endif      
  endfor
  slope_max_mean = mean(max_slope_parts);
  slope_max_SD = std(max_slope_parts);
  slope_5000 = slope(1:5000);
  slope_5000(slope_5000 > (slope_max_mean)) = [0];
  slope = [slope_5000,slope(5001:end)]; 
endfunction