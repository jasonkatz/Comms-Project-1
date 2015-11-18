function [numCorrect] = rxNew(sig, bits, gain)
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

for i = 0:15
    % Demodulate each channel into its own vector
    tonecoeff = i;
    carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
    rx = sig.*conj(carrier);
    rx = intdump(rx,nsamp);
    %% Recover your signal here

    % Demod 4-QAM
    rxMsg = qamdemod(rx,4);
    
    % Add new row to matrix
    msgCode = [msgCode ; rxMsg];
end

unleavedMsg = []; % lol
for i = 1:1024
    unleavedMsg = [unleavedMsg msgCode(:, i)'];
end

rx1 = de2bi(decodedMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

rxBits = de2bi(rx2);
rxBits = rxBits(:);

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