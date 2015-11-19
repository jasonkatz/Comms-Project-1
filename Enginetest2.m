clear all; clear global; clc; close all
noiseLevel  =  randi([0 20]);

% Sampling freq for specgram
Fs = 120e4;
sumForSpec = [];

total1 = 0;
total2 = 0;
for i = 1:15
    
   
    % Transmitters
    
    [sig1,bits1, gain1] = tx2();
    [sig2,bits2, gain2] = txNew2();
    
    sum = sig1 + sig2;
    sumNoisy = awgn(sum, noiseLevel, 1);
 
    
    % append;
    sumForSpec =  [sumForSpec, sumNoisy];
    
    x1 = rx2(sumNoisy, bits1, gain1)
    x2 = rxNew2(sumNoisy, bits2, gain2)

    
    % check the SER
   total1 = total1 + x1;
   total2 = total2 + x2;
end

noiseLevel
[total1, total2]
%spectrogram(sumForSpec,64,[],[],Fs,'yaxis')




