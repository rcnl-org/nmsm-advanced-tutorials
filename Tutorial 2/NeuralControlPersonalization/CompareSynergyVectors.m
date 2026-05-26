clear all
close all

import org.opensim.modeling.*

ncpResultsDirectory = "";

[muscleNames, synergyNumbers, synergyVectors] = parseMotToComponents(...
    Model(), Storage(fullfile(ncpResultsDirectory, "synergyWeights.sto")));

synergyVectors = normalizeSynergyData(synergyVectors', ...
    "magnitude", 1);

numSynergies = numel(synergyNumbers) / 2;

dotProducts = zeros(numel(synergyNumbers)/2);

rightVectors = synergyVectors(1:numSynergies, 1:numel(muscleNames)/2);
leftVectors = synergyVectors(numSynergies+1:numSynergies*2, numel(muscleNames)/2+1:numel(muscleNames));

for i = 1 : numSynergies
    for j = 1 : numSynergies
        dotProducts(i, j) = dot(rightVectors(i,:), leftVectors(j,:));
    end
end

rightLabels = "Right_" + synergyNumbers(1:numSynergies);
leftLabels = "Left_" + synergyNumbers(1:numSynergies);

rightTable = array2table(dotProducts, rowNames=rightLabels, VariableNames=leftLabels)

function synergyWeights = normalizeSynergyData(...
    synergyWeights, synergyNormalizationMethod, synergyNormalizationValue)
switch synergyNormalizationMethod
    case "sum"
        for i = 1:size(synergyWeights, 1)
            total = sum(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
        end
    case "magnitude"
        for i = 1:size(synergyWeights, 1)
            total = norm(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
        end
    otherwise
        throw(MException('', "Only 'sum' and 'magnitude' are " + ...
            "supported synergy normalization methods."))
end
end