function [numCorrect] = rxNew2(sig, bits, gain)
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

global intrlvrIndices;

%% I don't recommend touching the code below
% Generate a carrier

feedback1 = 1;

msgCode = [];

numChannels = 16;


%spectrogram(sig);
    
% Demodulate each channel into its own vector
tonecoeff = 0;
carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier);

%% Recover your signal here

rx = reshape(rx, 16, length(rx)/16);

rx = fft(rx, 16);

rx = rx(:);

% Demod 4-QAM
rxMsg = qamdemod(rx,4);

rx1 = de2bi(rxMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

% Undo the bit interleave
interRx = reshape(rx2, 128, 256).';
interRx = reshape(interRx, length(rx2), 1);

% 12270 added zeros
interRx = interRx(1:(length(interRx) - 12270));

frmLen = 4096;

hTDec = comm.TurboDecoder('TrellisStructure',poly2trellis(4, ...
    [13 15 17],13),'InterleaverIndices',intrlvrIndices, ...
    'NumIterations',4);

decodedMsg = step(hTDec,interRx);

%rxBits = de2bi(decodedMsg);
%rxBits = rxBits(:);
rxBits = decodedMsg;

% Check the BER. If zero BER, output the # of correctly received bits.
ber = biterr(rxBits, bits);

if ber == 0
    disp('Sucessful frame User 2')
    numCorrect = length(bits);
else 
   %scatterplot(rx); 
end


% set the new value for the feedback here
% You probably want to do somehting more intelligent

feedback1 = feedback1 + 1;

end