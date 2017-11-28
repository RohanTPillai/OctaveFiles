function [RRI_true_val,RRI_true_val_locs] = GetTrueRRI(RRI_data)
  RRI_true_val_locs = find(RRI_data ~= 0);
  RRI_true_val = RRI_data(RRI_data ~= 0);
endfunction