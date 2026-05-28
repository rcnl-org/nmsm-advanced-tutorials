close all

settingsFileName = "DOSettings.xml";

% DesignOptimizationTool(settingsFileName)

plotTreatmentOptimizationResultsFromSettingsFile(settingsFileName)

% IntegratedQuantitiesPreviewTool("PreviewIntegratedQuantitiesBefore.xml")
% 
% IntegratedQuantitiesPreviewTool("PreviewIntegratedQuantitiesAfter.xml")