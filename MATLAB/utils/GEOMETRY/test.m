%% TEST SCRIPT
close all
clear
clc

img = double(imread('imagen.jpeg'))/255;

figure, imshow(img,[]);
pause(1)
img = compensateRotation(img, 0.95);
figure, imshow(img,[]);

template = zeros(44,1,3);
template(1:11,:,2) = 1.0;
template(12:22,:,1) = 1.0;
template(23:33,:,3) = 1.0;

figure
img = fineTuneRotation(img,template,1);
