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

decodedMsg = [];

for i = 0:15

    tonecoeff = i;
    
    sigPart = sig((i * 1024 +1):((i + 1) * 1024));
    
    carrier = fskmod(tonecoeff*ones(1,64),M,fsep,nsamp,Fs);
    rx = sigPart.*conj(carrier);
    rx = intdump(rx,nsamp);
    %% Recover your signal here

    % Demod 4-QAM
    rxMsg = qamdemod(rx,4);
    correctedMsg = [];

    % Each channel has 64 symbols (4 sets of 16 (hopefully) repeated)
    for j = 0:15
        correctedMsg = [correctedMsg mode(rxMsg((j * 4 + 1):((j + 1) * 4)))];
    end
    
    decodedMsg = [decodedMsg correctedMsg];
    
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