mtpResultsRight = "..\MuscleTendonPersonalization\MTPResultsRight";
mtpResultsLeft = "..\MuscleTendonPersonalization\MTPResultsLeft";

rightActivationsFile = fullfile(mtpResultsRight, "muscleActivations", "gait_1_muscleActivations.sto");
leftActivationsFile = fullfile(mtpResultsLeft, "muscleActivations", "gait_1_muscleActivations.sto");
rightMomentsFile = fullfile(mtpResultsRight, "modelMoments", "gait_1_modelMoments.sto");
leftMomentsFile = fullfile(mtpResultsLeft, "modelMoments", "gait_1_modelMoments.sto");

if ~exist("mtpResultsCombined", "dir")
    mkdir("mtpResultsCombined")
end
if ~exist(fullfile("mtpResultsCombined", "muscleActivations"), "dir")
    mkdir(fullfile("mtpResultsCombined", "muscleActivations"))
end
if ~exist(fullfile("mtpResultsCombined", "modelMoments"), "dir")
    mkdir(fullfile("mtpResultsCombined", "modelMoments"))
end

[combinedMuscleNames, time, combinedMuscleActivations] = ...
    concatenateStoFiles(rightActivationsFile, leftActivationsFile);
[combinedJointNames, ~, combinedJointMoments] = ...
    concatenateStoFiles(rightMomentsFile, leftMomentsFile);

writeToSto(combinedMuscleNames, time, combinedMuscleActivations, ...
    fullfile("mtpResultsCombined", "muscleActivations", "gait_1_muscleActivations.sto"));
writeToSto(combinedJointNames, time, combinedJointMoments, ...
    fullfile("mtpResultsCombined", "modelMoments", "gait_1_modelMoments.sto"));
copyfile(fullfile(mtpResultsLeft, "*.osimx"), "mtpResultsCombined")

plotTreatmentOptimizationJointLoads(fullfile("mtpResultsCombined", ...
    "modelMoments", "gait_1_modelMoments.sto"), [])
plotTreatmentOptimizationMuscleActivations(fullfile("mtpResultsCombined", ...
    "muscleActivations", "gait_1_muscleActivations.sto"), [])

function [concatenatedLabels, time, concatenatedData] = concatenateStoFiles(file1, file2)
    import org.opensim.modeling.*
    [file1Labels, time, file1Data] = parseMotToComponents(Model(), Storage(file1));
    [file2Labels, ~, file2Data] = parseMotToComponents(Model(), Storage(file2));
    concatenatedLabels = [file1Labels, file2Labels];
    concatenatedData = [file1Data', file2Data'];
end