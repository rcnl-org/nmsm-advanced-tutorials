function convertGroundReactionsToCop(fileName)

% Matlab program to convert ground reaction data from electrical center
% format to center of pressure format for visualization purposes.
% Ground reaction data are stored in a .sto file and produced by GCP,
% TO, VO, or DO

% Author: B.J. Fregly 11/27/2024

% Read in data from ground reaction force file
infile = strcat(fileName,'.mot');
outfile = strcat(fileName,'_cop.mot');

data = importdata(infile);
textData = data.textdata;
time = data.data(:,1);
numData = data.data(:,2:end);

% Filter each column of ground reaction data using a 2nd order zero phase
% lag Butterworth lowerpass filter
[nRows,nCols] = size(numData);

% Determine number of force blocks, which is the same as number of force
% plates
forceBlocks = round(nCols/9);

% Change output format to CoP
fprintf('Converting from electrical center to CoP format . . .\n')

for j = 1:forceBlocks
    shift = (j-1)*9;

    for i = 1:nRows
    
        Fx = numData(i,1+shift);
        Fy = numData(i,2+shift);
        Fz = numData(i,3+shift);

        px = numData(i,4+shift);
        py = numData(i,5+shift);
        pz = numData(i,6+shift);

        Tx = numData(i,7+shift);
        Ty = numData(i,8+shift);
        Tz = numData(i,9+shift);

        qy = 0;
        qx = px+(Tz-Fx*(py-qy))/Fy;
        qz = pz-(Tx+Fz*(py-qy))/Fy;

        TyFree = Ty + Fx*(pz-qz) - Fz*(px-qx);

        numData(i,4+shift) = qx;
        numData(i,5+shift) = qy;
        numData(i,6+shift) = qz;

        numData(i,7+shift) = 0;
        numData(i,8+shift) = TyFree;
        numData(i,9+shift) = 0;
    end
end

% Output ground reaction data in center of pressure format
fid = fopen(outfile,'w');

fprintf('Outputting ground reaction data to file %s . . .\n', outfile)

[nHeaderRows,nHeaderCols] = size(textData);

for i = 1:nHeaderRows-1
    fprintf(fid,'%s\n',textData{i,1});
end

for i = 1:nHeaderCols-1
    fprintf(fid,'%s\t',textData{nHeaderRows,i});
end
fprintf(fid,'%s\n',textData{nHeaderRows,nHeaderCols});

for i = 1:nRows
    % fprintf('Writing row %d . . .\n', i)
    
    fprintf(fid,'%20.14f\t',time(i,1));
    
    for j = 1:nCols-1
        fprintf(fid,'%20.14f\t',numData(i,j));
    end
    
    fprintf(fid,'%20.14f\n',numData(i,nCols));
end

fclose(fid);

end
