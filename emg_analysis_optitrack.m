%% análisis de fuerza y fatiga de la señal electromiográfica obtenida

% Con este programa se selecciona el archivo que se quiere analizar y, de
% ese archivo, el sensor (en caso de que haya más de uno). 
% Del archivo se obtendrá la información del tiempo y la amplitud del
% sensor elegido, a la cual se elimina el offset. La frecuencia de muestreo
% será obtenida para cálculos posteriores.
% Se llevan a cabo funciones para obtener la frecuencia media, mediana, la
% RMS y un análisis de frecuencia de la señal.
% Estos datos obtenidos son representados gráficamente para observar el
% comportamiento de la señal.
 
%% elección del archivo y sensor a analizar

clear
clc

% selección del archivo a analizar
[filename, path] = uigetfile('*.csv'); 
csvpath = fullfile(path,filename); 
take = readmatrix(csvpath);
take = take(16:end,:);

% selección de sensor a analizar
muscle = input("¿Qué sensor desea analizar?\nEn caso de ser sólo uno escriba '1'\n");

%% guardado de las variables

% extracción del tiempo en segundos
t = take(:,3)/1200;

% extracción de la fecuencia de muestreo. sec_diff obtiene la diferencia de
% tiempo entre una muestra y la siguiente de toda la grabación. se hace la
% media de los valores obtenidos para obtener el periodo de muestreo
% (samp_rate) y al dividirlo entre uno, obtener la frecuencia de muestreo
% (fs), la cual es redondeada a la baja por precaución.
sec_diff = zeros(1,length(take)-2);
for i = 1:length(take)-2
    sec_diff(i) = take(i+1,3)/1200-take(i,3)/1200;
end
samp_rate = mean(sec_diff);
fs = floor(1/samp_rate);

% eliminar frecuencia de muestreo. obtención de los primeros cinco
% segundos los cuales representan un estado de reposo, en el que sólo está
% presente el ruido basal. obtención de la media (offset) de ese fragmento 
% y resta a la amplitud de la señal (y). obtención de la señal rectificada
% (y1) mediante el uso de un valor absoluto.
offset = mean(take(1:(3*fs),muscle+3));
y = take(:,muscle+3) - offset;
y1 = abs(take(:,muscle+3) - mean(take(:,muscle+3)));

% longitud de la muestra (l) y tamaño de la ventana (window_length),
% obtenida mediante la multiplicación de cuántos segundos de ventana se
% quieren usar por la frecuencia de muestreo
l = length(take);
window_length = round(0.125*fs);

%% moving average

% obtener la frecuencia media de la señal (avgy)
coeff = ones(1, window_length)/window_length;
avgy = filter(coeff, 1, y1);

%% análisis de frecuencia

% obtención de la potencia de cada frecuencia (power) mediante el uso de la 
% fast fourier transform
xdft = fft(y);
n = length(y);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(xdft).^2/n;    % power of the DFT

% centrado de la potencia obtenida (power0)
y0 = fftshift(xdft);         % shift y values
f0 = (-n/2:n/2-1)*(fs/n); % 0-centered frequency range
power0 = abs(y0).^2/n;    % 0-centered power

%% moving median

% obtención de la frecuencia mediana de la señal (m)
m = movmedian(y1,window_length);

%% rms

% obtención de la envolvente de la señal (rms)
rms = sqrt(movmean(y1.^2, window_length));

%% representación gráfica

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
plot(t,[y1 rms])
title("RMS (overlaid)")
xlabel("Time(s)")
ylabel("Amplitude (V)")