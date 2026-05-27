function cropGaitData(trialName,tStart,tEnd)

% Matlab program to crop input Tracking Optimization data files down to
% a single gait cycle defined by a specified start time and end time.
%
% Inputs: trialName - Name of experimental trial for IK, ID, and GRF
%             data files
%             <trialName>_IK_results_filtered.mot
%             <trialName>_ID_results.sto
%             <trialName>_forces_filtered_updated.mot
%         tStart - Starting time value for selected gait cycle
%         tEnd - Ending time value for selected gait cycle.
%
% Outputs: Input data files cropped to one gait cycle for Tracking
%         Optimization (time redefined starting from 0)
%             <trialName>_IK_results_filtered_cropped.sto
%             <trialName>_ID_results_cropped.sto
%             <trialName>_forces_filtered_updated_cropped.sto
%
% Author: B.J. Fregly 10/13/2025

close all

if nargin < 3
    trialName = 'Trial12_Gait';
	tStart = 2.235;
	tEnd = 3.280;
end

% Loop through the three file types and crop each input data file

for dataType = 1:3

    switch dataType

        case 1
            infile = strcat(trialName,'_IK_results_filtered.mot');
            outfile = strcat(trialName,'_IK_results_filtered_cropped.sto');

        case 2
            infile = strcat(trialName,'_ID_results.sto');
            outfile = strcat(trialName,'_ID_results_cropped.sto');

        case 3
            infile = strcat(trialName,'_forces_filtered_updated.mot');
            outfile = strcat(trialName,'_forces_filtered_updated_cropped.sto');

    end

    cropData(infile,outfile,tStart,tEnd,dataType);

end

end

%==========================================================================
function cropData(infile,outfile,tStart,tEnd,dataType)

fprintf('Reading in data file %s . . .\n', infile)
data = importdata(infile);

textData = data.textdata;
time = data.data(:,1);
dt = time(2,1)-time(1,1);
numData = data.data(:,2:end);
nRows = size(numData,1);

% Determine data rows corresponding to specified time range
for i = 1:nRows
    startDiff = abs(time(i,1)-tStart);
    endDiff = abs(time(i,1)-tEnd);

    if startDiff < 1e-8
        startRow = i;
    end

    if endDiff < 1e-8
        endRow = i;
        break
    end

end

% Crop data to specified time range
numDataCropped = numData(startRow:endRow,:);
[nRowsCropped,nColsCropped] = size(numDataCropped);
timeCropped = [linspace(0,nRowsCropped-1,nRowsCropped)*dt]';

% Update output headers
textDataCropped = cell(5,nColsCropped+1);
textDataCropped{1,1} = sprintf('DataType=double');
textDataCropped{2,1} = sprintf('version=3');
textDataCropped{3,1} = sprintf('OpenSimVersion=4.5');
textDataCropped{4,1} = sprintf('endheader');

switch dataType

    case 1
        % Change units for joint rotations if necessary
        inDegrees = strfind(textData{5,1},'yes');

        if inDegrees
            convertCols = [1:3 7:nColsCropped];
            numDataCropped(:,convertCols) = ...
                numDataCropped(:,convertCols)*pi/180.0;
        end

        % Update column labes for last line of header
        textDataCropped(5,:) = textData(9,:);

    case 2
        % Update column labes for last line of header
        textDataCropped(5,:) = textData(7,:);

    case 3
        % Update column labes for last line of header
        textDataCropped(5,:) = textData(5,:);

end

% Output cropped data
fid = fopen(outfile,'w');

fprintf('Outputting data file %s . . .\n', outfile)

[nHeaderRows,nHeaderCols] = size(textDataCropped);

for i = 1:nHeaderRows-1
    fprintf(fid,'%s\n',textDataCropped{i,1});
end

for i = 1:nHeaderCols-1
    fprintf(fid,'%s\t',textDataCropped{nHeaderRows,i});
end
fprintf(fid,'%s\n',textDataCropped{nHeaderRows,nHeaderCols});

for i = 1:nRowsCropped
    fprintf(fid,'%20.14f\t',timeCropped(i,1));

    for j = 1:nColsCropped-1
        fprintf(fid,'%20.14f\t',numDataCropped(i,j));
    end

    fprintf(fid,'%20.14f\n',numDataCropped(i,nColsCropped));
end

fclose(fid);

end
