clear all
clc

[filename, path] = uigetfile('*.xlsx'); 
csvpath = fullfile(path,filename); 
take = readmatrix(csvpath);
muscle = input("¿Qué sensor desea analizar?\nEn caso de ser sólo uno escriba '1'\n");
t = take(:,1);
offset = mean(take(1:(5*1250),muscle+1));
y = take(:,muscle+1) - offset;
y1 = abs(take(:,muscle+1) - mean(take(:,muscle+1)));
fs = 1250;
l = length(take);
window_length = 2000;
coeff = ones(1, window_length)/window_length;

avgy = filter(coeff, 1, y1);

xdft = fft(y);
n = length(y);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(xdft).^2/n;    % power of the DFT

y0 = fftshift(xdft);         % shift y values
f0 = (-n/2:n/2-1)*(fs/n); % 0-centered frequency range
power0 = abs(y0).^2/n;    % 0-centered power


m = movmedian(y1,window_length);

[yupper,ylower] = envelope(y1,window_length,'rms');

figure(1)

subplot(2,2,1)
plot(t,[y1 avgy])
title("Average frequency")
xlabel("Time(s)")
ylabel("Amplitude (V)")

subplot(2,2,2)
plot(f0,power0)
title("Frequency analysis")
xlim([0 fs/2])
xlabel('Frequency')
ylabel('Power')

subplot(2,2,3)
plot(t,[y1 m])
title("Median frequency")
xlabel("Time(s)")
ylabel("Amplitude (V)")

subplot(2,2,4)
plot(t,[y1 yupper])
title("RMS (overlaid)")
xlabel("Time(s)")
ylabel("Amplitude (V)")