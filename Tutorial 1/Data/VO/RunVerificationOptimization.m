close all

VerificationOptimizationTool("Completed\VO_Settings_HTO.xml")

% If running this line without running line 3 on your own, copy the results
% directories out of the "Completed" folder.
plotTreatmentOptimizationResultsFromSettingsFile("Completed\VO_Settings_HTO.xml")

VerificationOptimizationTool("Completed\VO_Settings_MTG.xml")

% If running this line without running line 9 on your own, copy the results
% directories out of the "Completed" folder.
plotTreatmentOptimizationResultsFromSettingsFile("Completed\VO_Settings_MTG.xml")