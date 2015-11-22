clc; clear all; close all;

code = randi([0 1], 32768, 1);

% Interleave
interCode = reshape(code, 256, 128).';
interCode = reshape(interCode, length(code), 1);

interRx = reshape(interCode, 128, 256).';
interRx = reshape(interRx, length(interCode), 1);

sum(code == interRx) == length(code)