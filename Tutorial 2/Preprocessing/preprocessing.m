% This function is part of the NMSM Pipeline, see file for full license.
%
% Use this script to process your EMG, IK, ID, and MuscleAnalysis data in
% preparation for the other NMSM Pipeline tools. This script is intended to
% be used after Joint Model Personalization and the IK, ID, and
% MuscleAnalysis data for this script should be generated through the 
% OpenSim GUI tools. 
%
% Modify the script below with your own filenames and preferred settings.

%% Modify file names here:
modelFileName = fullfile("..", "UF_Subject_4_Scaled_JMP.osim");
processedEmgFileName = fullfile("..", "InputData", "Trial10_emg_processed.sto");
ikFileName = fullfile("..", "InputData", "Trial10_IKResults.mot");
idFileName = fullfile("..", "InputData", "Trial10_IDResults.sto");
grfFileName = fullfile("..", "InputData", "Trial10_forces_ec_reordered_filtered.mot");
muscleAnalysisDirectory = fullfile("..", "MuscleAnalysis", "MADataNew");
trialNames = "Trial10";
startTime = 0.29;
endTime = 1.41;

%% Preprocessing Script

% % All values required
% rawEmgFileName = "..\prepare_data_for_mtp\Trial01_emg.mot";
% filterOrder = 4;
% highPassCutoff = 40;
% lowPassCutoff = 3.5 / 1;
% processedEmgFileName = "..\prepare_data_for_mtp\Trial01_emg_processed.mot";
% 
% processRawEmgFile(rawEmgFileName, filterOrder, highPassCutoff, ...
%     lowPassCutoff, processedEmgFileName);


%% Create Muscle Tendon Velocity
% Calculates muscle-tendon velocity using B-splines and MuscleAnalysis's
% muscle-tendon length. The file is written in the same directory as the
% muscle-tendon length file.
trialPrefixes = ["gait"];

cutoffFrequency = 6.25;
muscleTendonLengthFileName = fullfile(MADataDirectory, strcat(trialNames+"_MuscleAnalysis_Length.sto"));
createMuscleTendonVelocity(muscleTendonLengthFileName, cutoffFrequency);

%% Split OpenSim data into trials by time pairs

% Required: pairs of start/end time of events to be extracted
trialTimePairs = [startTime endTime];
splineCutoffFrequency = 6.25;

% Required: Associated .osim model file
inputSettings.model = modelFileName;

% All values optional: files and directories of data to be split
inputSettings.ikFileName = ikFileName;
inputSettings.idFileName = idFileName;
inputSettings.emgFileName = processedEmgFileName;
inputSettings.grfFileName = grfFileName;
inputSettings.maDirectory = MADataDirectory;
inputSettings.cutoffFrequency = splineCutoffFrequency;
inputSettings.rowsPerTrial = 101;

% All values optional: output information, uses default values otherwise
outputSettings.resultsDirectory = "preprocessed";

% The trial prefix is the prefix of each output file, identifying the
% motion such as 'gait' or 'squat' or 'step_up'.
outputSettings.trialPrefix = trialPrefixes;

splitIntoTrials( ...
    trialTimePairs, ...
    inputSettings, ...
    outputSettings ...
    )