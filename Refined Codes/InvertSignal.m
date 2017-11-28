function c = InvertSignal(data,invert_flag)
  if invert_flag == 0
    % Non-inverted signal  
    c = data;  
    c = c + abs(min(c));
  else
    % Inverted signal 
    c = -data;  
    c = c - min(c);  
  endif
endfunction