% Run all the passive moment data through muscle analysis
% Import OpenSim Libraries into MATLAB
import org.opensim.modeling.*

%% Edit these variables
thelenFolder = "";  % either thelen_r or thelen_l
modelFileName = ""; % path to your osim model file

if ~exist(fullfile(thelenFolder, "MAData"), "dir")
    mkdir(fullfile(thelenFolder, "MAData"))
end

% Load an OpenSim Model (replace with the path to your .osim model file)
model = Model(modelFileName);
model.initSystem();

% Load the analysis settings from XML file (replace with your .xml settings file)
analysisSettingsFile = 'passive_moment_analysis.xml';
analysisTool = AnalyzeTool(analysisSettingsFile);

% Make sure the correct model file is referenced (optional if already set in XML)
analysisTool.setModel(model);

jointNames = {'Ankle','Hip','Knee'};

for i = 1:4
    for jointNum = 1:3
        jointName = jointNames{jointNum};
        ikFileName = fullfile(thelenFolder, "IKData", strcat("Thelen_", jointName, "Passive_0", num2str(i), ".mot"));
        resultsDirectory = fullfile(thelenFolder, "MAData", strcat("Thelen_", jointName, "Passive_0", num2str(i)));
        prefixName = strcat("Thelen_", jointName, "Passive_0", num2str(i));

        % Change the settings
        analysisTool.setCoordinatesFileName(ikFileName);
        analysisTool.setName(prefixName);    
        analysisTool.setResultsDir(resultsDirectory);

        % Print the file
        analysisTool.print(analysisSettingsFile);

        % Reload the tool
        analysisTool = AnalyzeTool(analysisSettingsFile);
        analysisTool.getName()

        % Run the analysis
        fprintf('Running Analysis for ');
        fprintf(jointName);
        fprintf(num2str(i));
        fprintf('...\n');
        analysisTool.run();
        fprintf('Analysis completed.\n');
    end
end