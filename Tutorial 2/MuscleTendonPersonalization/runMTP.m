close all

rightSettingsFileName = "MTPSettingsRight.xml";
leftSettingsFileName = "MTPSettingsLeft.xml";

% MuscleTendonPersonalizationTool(rightSettingsFileName)
% MuscleTendonPersonalizationTool(leftSettingsFileName)

plotMtpResultsFromSettingsFile(rightSettingsFileName)
plotMtpResultsFromSettingsFile(leftSettingsFileName)