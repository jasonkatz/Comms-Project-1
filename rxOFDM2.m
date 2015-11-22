function [numCorrect] = rxOFDM2(sig, bits, gain)
%% Receive input sig, compute BER relative to bits

% DO NOT TOUCH BELOW
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;
%M = 4; fsep = 8; nsamp = 8; Fs = 32;

% THE ABOVE CODE IS PURE EVIL

numCorrect = 0; % initialize the # of correct Rx bits
% Global variable for feedback
global feedback1;
uint8(feedback1);

%% I don't recommend touching the code below
% Generate a carrier

msgCode = [];

numChannels = feedback1;

%spectrogram(sig);
    
% Demodulate each channel into its own vector
tonecoeff = 0;
carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier);

% Downsample for cases where numChannels isn't 16
rx = intdump(rx, 16 / numChannels);

%% Recover your signal here

rx = reshape(rx, numChannels, length(rx)/numChannels);

rx = fft(rx, numChannels);

rx = rx(:);

% Demod 4-QAM
rxMsg = qamdemod(rx,4);

rx1 = de2bi(rxMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

% Remove padded zeros
if numChannels == 16
    rx2 = rx2(1:(length(rx2) - 12270));
elseif numChannels == 8
    rx2 = rx2(1:(length(rx2) - 6126));
elseif numChannels == 4
    rx2 = rx2(1:(length(rx2) - 3054));
end

load('interleaverIndices.mat'); % Load indices
% Only take what we need based on the channels we're using
if numChannels == 16
    intrlvrIndices = intrlvrIndices4096;
elseif numChannels == 8
    intrlvrIndices = intrlvrIndices2048;
elseif numChannels == 4
    intrlvrIndices = intrlvrIndices1024;
end
hTDec = comm.TurboDecoder('TrellisStructure',poly2trellis(4, ...
    [13 15 17],13),'InterleaverIndices',intrlvrIndices, ...
    'NumIterations',4);

decodedMsg = step(hTDec,rx2);

%rxBits = de2bi(decodedMsg);
%rxBits = rxBits(:);
rxBits = decodedMsg;

% Check the BER. If zero BER, output the # of correctly received bits.
ber = biterr(rxBits, bits);

%rxBits == bits

if ber == 0
    disp('Sucessful frame User 2')
    numCorrect = length(bits);
else 
   %scatterplot(rx); 
end


% set the new value for the feedback here
% Use feedback to give the transmitter the SNR
totalPower = norm(sig);
if totalPower < 194
    feedback1 = 16;
elseif totalPower > 207
    feedback1 = 4;
else
    feedback1 = 8;
end

end