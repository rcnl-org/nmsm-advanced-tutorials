function calcOptimalHTOCorrections

close all

% Read in results from VO run and three DO runs with different amounts
% of valgus alignment correction
[data,~]=xlsread('Optimal HTO Corrections.xlsx');

target = -data(1,2);
correction = data(4:6,1);
rightPeak = -data(4:6,2);
leftPeak = -data(4:6,3);

% Fit a quadratic to the four data points for each leg
% p = a0 + a1*c+a2*c^2 where p is the peak knee adduction moment magnitude
% and c is the angle of correction
% Solve a linear least squares problem A*x = b where
% x = [a0; a1; a2];
A = [ones(3,1) correction correction.^2];
br = rightPeak;
xr = A\br;
bl = leftPeak;
xl = A\bl;

% Plot data and fitted peak adduction moment magnitudes
pr = A*xr;
pl = A*xl;

subplot(1,2,1), plot(correction,leftPeak,'k*',correction,pl,'bo')
axis([2 10 20 40])
subplot(1,2,2), plot(correction,rightPeak,'k*',correction,pr,'ro')
axis([2 10 20 40])

% Solve the quadratic equation for rightCorrection and leftCorrection
% p = a0 + a1*c+a2*c^2 becomes
% a2*c^2+a1*c+(a0-p) = 0
% which has solution
% c = (-a1+/-sqrt(a1^2-4*a2*(a0-p)))/(2*a2)
p = target;
% Right side
a0 = xr(1,1);
a1 = xr(2,1);
a2 = xr(3,1);
rightCorrection = (-a1-sqrt(a1^2-4*a2*(a0-p)))/(2*a2);
rightCorrectionRad = rightCorrection*pi/180;
fprintf('The right correction angle is %4.2f deg or %6.4f rad\n',...
    rightCorrection, rightCorrectionRad);
% Left side
a0 = xl(1,1);
a1 = xl(2,1);
a2 = xl(3,1);
leftCorrection = (-a1-sqrt(a1^2-4*a2*(a0-p)))/(2*a2);
leftCorrectionRad = leftCorrection*pi/180;
fprintf('The left correction angle is %4.2f deg or %6.4f rad\n',...
    leftCorrection,leftCorrectionRad)

end
