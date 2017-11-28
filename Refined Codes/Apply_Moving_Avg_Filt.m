function c_filtered = Apply_Moving_Avg_Filt(c,window_size,c_length)
  c_filtered = zeros(1,c_length);
  for i = 1:c_length
    if i < window_size
      c_window = c(1:i);  
      c_filtered(i) = sum(c_window)/length(c_window);
    else
      c_window = c(i-window_size+1:i);  
      c_filtered(i) = sum(c_window)/length(c_window);
    endif
  endfor
endfunction