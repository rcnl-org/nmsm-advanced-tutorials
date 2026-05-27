function filterIKResults(trialName,order,filtCutoff,plotFlag)

% Matlab program to filter IK results from a long motion trial
%
% Inputs: trialName - Name of experimental trial for IK data file
%             <trialName>_IK_results.mot
%         order - filter order, usually 4
%         fCutoff - filter cutoff frequency, usually 6
%         plotFlag - flag (0 or 1) to plot filtered curves
%
% Outputs: Output filtered IK data file
%             <trialName>_IK_results_filtered.mot
%
% Author: B.J. Fregly 9/17/2025

close all

if nargin < 4
    trialName = 'Trial12_Gait';
    order = 4;
    filtCutoff = 6;
    plotFlag = 1;
end

% Load trial of IK data
infile = strcat(trialName,'_IK_results.mot');
data = importdata(infile);

textData = data.textdata;
time = data.data(:,1);
dt = time(2,1)-time(1,1);
numData = data.data(:,2:end);
[nRows,nCols] = size(numData);

% Loop through data columns and lowpass filter
numDataFilt = zeros(nRows,nCols);

for k = 1:nCols
    fprintf('Filtering generalized coordinate %s . . .\n',sprintf(textData{9,k+1}))
    numDataFilt(:,k) = lowpassFilter(time,numData(:,k),order,filtCutoff,plotFlag);
end

% Convert output joint angles from deg to rad if necessary
if strcmp(textData{5,1},'inDegrees=yes')
    fprintf('Converting rotations from degrees to radians . . .\n')

    numDataFilt(:,[1:3 7:nCols]) = numDataFilt(:,[1:3 7:nCols])*pi/180;
    textData{5,1} = 'inDegrees=no';
end

% Copy knee_angle values to knee_angle_beta values
numDataFilt(:,13) = numDataFilt(:,10);
numDataFilt(:,23) = numDataFilt(:,20);

% Output filtered inverse kinematics data
outfile = strcat(trialName,'_IK_results_filtered.mot');
fid = fopen(outfile,'w');

fprintf('Outputting filtered IK data to file %s . . .\n', outfile)

[nHeaderRows,nHeaderCols] = size(textData);

for i = 1:nHeaderRows-1
    fprintf(fid,'%s\n',textData{i,1});
end

for i = 1:nHeaderCols-1
    fprintf(fid,'%s\t',textData{nHeaderRows,i});
end
fprintf(fid,'%s\n',textData{nHeaderRows,nHeaderCols});

for i = 1:nRows
    fprintf(fid,'%20.14f\t',time(i,1));
    
    for j = 1:nCols-1
        fprintf(fid,'%20.14f\t',numDataFilt(i,j));
    end
    
    fprintf(fid,'%20.14f\n',numDataFilt(i,nCols));
end

fclose(fid);

end

%--------------------------------------------------------------------------
function yFilt = lowpassFilter(t,y,order,fCutoff,plotFlag)
% Perform zero phase-lag lowpass Butterworth filter on input data

% Set up filter inputs
dt = t(2,1)-t(1,1);
fSample = 1/dt; % Sampling frequency in Hz
normCutoff = fCutoff/(fSample/2);

% Create butterworth filter
[b,a] = butter(order,normCutoff);

% Demean input data to minimize edge effects
yMean = mean(y);
yDemeaned = y-yMean;

% Use filtfilt to perform zero phase-lag filtering on demeaned data
yFiltDemeaned = filtfilt(b,a,yDemeaned);

% Add mean value back into filtered data
yFilt = yFiltDemeaned+yMean;

% Plot original and filtered data if desired
if plotFlag
    plot(t,y,'k-')
    hold on
    plot(t,yFilt,'b-')
    xlabel('time')
    ylabel('data')
    pause
    close all
end

end

