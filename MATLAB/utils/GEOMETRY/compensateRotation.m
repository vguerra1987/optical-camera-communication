function out = compensateRotation(img,alfa)
% This function compensates the rotation of a misaligned OCC Tx.
% img is the input image in which rolling shutter images can be observed
% alfa is the energy percentile from which each row will be considered to
% carry out the rotation.

GRAY = double(rgb2gray(img));

devs = zeros(1,size(GRAY,1));
varTest = zeros(1,size(GRAY,1));
xBase = (1:size(GRAY,2))';

for J = 1:size(GRAY,1)
    row = GRAY(J,:);
    devs(J) = row*xBase/sum(row);
    varTest(J) = std(row);
end

[C,X] = ecdf(varTest);
Xth = X(C>alfa);
Xth = Xth(1);

indices = find(varTest >= Xth);

F = fit(indices', devs(indices)','poly1');

angle = atan(F.p1)*180/pi;

out = imrotate(img, -angle);