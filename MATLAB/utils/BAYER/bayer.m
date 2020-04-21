%% BAYER ESTIMATION
clear all
close all
clc


%% COLORS
BLUE = [255 155 74];
GREEN = [238 86 167];
RED = [31 237 227];
MONO = [131 131 131];
LINE = [216 216 216];
BACK = [0 0 0];

%% SCRIPT CORE
IMG = double(imread('bayer_inverted.png'));
imshow(IMG);

minX = 400;
maxX = 1000;

minY = 0;
maxY = 0.8;

redQE = zeros(1,size(IMG,2));
greenQE = zeros(1,size(IMG,2));
blueQE = zeros(1,size(IMG,2));

for I = 1:size(IMG,2)
   line = squeeze(IMG(:,I,:));
   DBLUE = getDistances(line, BLUE);
   DRED = getDistances(line, RED);
   DGREEN = getDistances(line, GREEN);

   redQE(I) = massCenter(DRED,800);
   greenQE(I) = massCenter(DGREEN,600);
   blueQE(I) = massCenter(DBLUE,1000);
   
end

% At this point we have the points, but we must conver them to real QE
redQE = (1 - redQE/size(IMG,1))*maxY;
greenQE = (1 -  greenQE/size(IMG,1))*maxY;
blueQE = (1 - blueQE/size(IMG,1))*maxY;

wavelengths = linspace(minX, maxX, size(IMG,2));

figure(1);
plot(wavelengths, redQE,'r');
hold on;
plot(wavelengths, greenQE,'g');
plot(wavelengths, blueQE,'b');

% Now we must transform quantum efficiency to responsivity
redR = redQE.*wavelengths/1000/1.23985;
greenR = greenQE.*wavelengths/1000/1.23985;
blueR = blueQE.*wavelengths/1000/1.23985;

figure(2);
plot(wavelengths, redR,'r');
hold on;
plot(wavelengths, greenR,'g');
plot(wavelengths, blueR,'b');

%% USEFUL FUNCTIONS
% Distance calculation
function dist = getDistances(vector, target)

dist = zeros(1, size(vector,1));

for I = 1:length(dist)
   dist(I) = sum((vector(I,:) - target).^2);
end
end

% massCenter estimation
function pos = massCenter(distances, threshold)

indices = 1:length(distances);

indices(distances >= threshold) = [];
distances(distances >= threshold) = [];

pos = indices*distances'/sum(distances);
end