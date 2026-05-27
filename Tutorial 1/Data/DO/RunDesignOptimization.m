close all

DesignOptimizationTool("Completed\DO_Settings_HTOOpt.xml")

% If running this line without running line 3 on your own, copy the results
% directories out of the "Completed" folder.
plotTreatmentOptimizationResultsFromSettingsFile("Completed\DO_Settings_HTOOpt.xml")

DesignOptimizationTool("Completed\DO_Settings_MTG.xml")

% If running this line without running line 9 on your own, copy the results
% directories out of the "Completed" folder.
plotTreatmentOptimizationResultsFromSettingsFile("Completed\DO_Settings_MTG.xml")