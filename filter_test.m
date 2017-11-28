clc
clear all
%close all
data = csvread('C:\Users\rohanp\Documents\EXPORTED ECG DATA\Rohan Test Recordings\Chronovisor Current Algo Results\brigitte  subject 25.csv');

%% Manage Inverted/Non-Inverted Signal
c = data(:,3);
data_invert_flag = 0;                                                           % 1 if data is to be inverted, else 0
c = InvertSignal(c,data_invert_flag);
c_length = length(c);

window_size = 10;
c_filtered = Apply_Moving_Avg_Filt(c,window_size,c_length);

c_filtered = c_filtered - max(c);

figure
plot(c);
hold on
plot(c_filtered);