close all

SettingsFileName = "VOSettings.xml";

% VerificationOptimizationTool(SettingsFileName)

plotTreatmentOptimizationResultsFromSettingsFile(SettingsFileName)

% Uncomment the line below to plot the failed VO results that are asked
% about in the deliverables.
% plotTreatmentOptimizationResultsFromSettingsFile(SettingsFileName, "VOResultsFailed")