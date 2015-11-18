function [tx, bits, gain] = txNew()
% Example Transmitter. Outputs modulated data tx, and original data stream
% data for checking error rate at receiver.
% Your team will be assigned a number, rename your function txNUM.m
% Also rename the global variable tofeedbackNUM

% Global variable for feedback
% you may use the following uint8 for whatever feedback purposes you want
global feedback1;
uint8(feedback1);

% You can use global variables to maintain state of your tx, so long as you
% do not use this information in the Rx
% I am going to use the global to toggle time slots, and simply alternate
% between transmitting and not transmitting
global stateVal


% DO NOT TOUCH BELOW
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;   % THIS IS THE M-ARY # for the FSK MOD.  You have 16 channels available
% THE ABOVE CODE IS PURE EVIL



% initialize, will be set by rx after 1st transmission
if isempty(feedback1)
    feedback1 = 0;
    stateVal = 0;
end

%% You should edit the code starting here

msgM = 4; % Select 4 QAM for my message signal
k = log2(msgM);

% You may use as many BITS as you wish, but must transmit exactly 1024
% SYMBOLS
bits = randi([0 1],8192*k,1); % Generate random bits, pass these out of function, unchanged
%bits = ones(64*k,1);

% Construct trellis for rate 1/2 conv code
trellis = struct('numInputSymbols',2,'numOutputSymbols',4,...
'numStates',4,'nextStates',[0 2;0 2;1 3;1 3],...
'outputs',[0 3;1 2;3 0;2 1]);

% Encode bits
code = convenc(bits, trellis);

% Convert to symbols
syms = bi2de(reshape(code,k,length(code)/k).','left-msb')';

% Random 4-QAM Signal
msg = qammod(syms,4);
msglength = length(msg);

if(msglength ~= 16384)
    error('You smurfed up')
end
    
tx = zeros(1, 16384);

for i = 1:16
    
    tonecoeff = i - 1;
    
    % Interleave 1024 symbols per channel
    msgPart = msg(i:M:msglength);
    partLength = length(msgPart);
    
    if(partLength ~= 1024)
        error('You smurfed up')
    end

    %% You should stop editing code starting here

    %% Serioulsy, Stop.

    % Generate a carrier
    % don't mess with this code either, just pick a tonecoeff above from 0-15.
    carrier = fskmod(tonecoeff*ones(1,partLength),M,fsep,nsamp,Fs);
    %size(carrier); % Should always equal 1024
    % upsample the msg to be the same length as the carrier
    msgUp = rectpulse(msgPart,nsamp);

    % multiply upsample message by carrier  to get transmitted signal
    txi = msgUp.*carrier;
    tx = tx + txi;

end

% scale the output
gain = std(tx);
tx = tx./gain;


if(stateVal ==0) % if i'm not allowed to transmit, just set bits to all 0
  tx = zeros(size(tx));
  gain = 1;
  stateVal = 1;
else
    stateVal = 0;
end


end