% Model (.osim) file used in Treatment Optimization
modelFileName = fullfile("..", "UF_Subject_4_Scaled_JMP.osim");

% Reference kinematics file for coordinate sampling
referenceKinematicsFile = fullfile("..", "Preprocessing", "preprocessed", ...
    "IKData", "gait_1.sto");

% Output directory name
surrogateDataDirectoryName = fullfile("surrogateData");

% Number of LHS points per time point
settings.samplePoints = 25;

% Default padding (radians) for rotational coordinate sampling
settings.angularPadding = deg2rad(20);

% Default padding (meters) for translational coordinate sampling
settings.linearPadding = 0.1;

% Padding ranges specific to coordinates. The deepest struct field name
% must exactly match a coordinate name in the reference kinematics file.
% Coordinates without a specified range will use positive and negative
% default padding for their ranges. 
% 
% Example: settings.padding.hip_flexion_r = [-0.1, 0.2];
settings.padding = struct();
% settings.padding.hip_flexion_r = [-deg2rad(20),deg2rad(20)];
settings.padding.hip_adduction_r = [-deg2rad(15),deg2rad(15)];
settings.padding.hip_rotation_r = [-deg2rad(10),deg2rad(10)];
% settings.padding.hip_flexion_l = [-deg2rad(20),deg2rad(20)];
settings.padding.hip_adduction_l = [-deg2rad(15),deg2rad(15)];
settings.padding.hip_rotation_l = [-deg2rad(10),deg2rad(10)];
% settings.padding.knee_angle_r = [-deg2rad(40),deg2rad(10)];
% settings.padding.knee_adduction_r = [0 0];
% settings.padding.ankle_angle_r = [-deg2rad(25),deg2rad(15)];
% settings.padding.hip_rotation_l = [-deg2rad(10),deg2rad(30)];
% settings.padding.knee_angle_l = [-deg2rad(35),deg2rad(20)];
% settings.padding.knee_adduction_l = [0 0];
% settings.padding.lumbar_extension = [-deg2rad(20),deg2rad(15)];
% settings.padding.lumbar_bending = [-deg2rad(5),deg2rad(15)];
% settings.padding.lumbar_rotation = [-deg2rad(10),deg2rad(10)];


% End of user-defined settings

model = Model(modelFileName);
[coordinateNames, ~, referenceKinematics] = parseMotToComponents( ...
    model, org.opensim.modeling.Storage(referenceKinematicsFile));
referenceKinematics = referenceKinematics';
lhsKinematics = sampleSurrogateKinematicsFromSettings(model, ...
    referenceKinematics, coordinateNames, settings);

[~, trialName, ~] = fileparts(referenceKinematicsFile);
if ~exist(surrogateDataDirectoryName, "dir")
mkdir(surrogateDataDirectoryName);
end
if ~exist(fullfile(surrogateDataDirectoryName, "MAData"), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "MAData"));
end
if ~exist(fullfile(surrogateDataDirectoryName, "MAData", trialName), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "MAData", trialName));
end
if ~exist(fullfile(surrogateDataDirectoryName, "IKData"), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "IKData"));
end
ikFileName = fullfile(surrogateDataDirectoryName, "IKData", ...
    trialName + ".sto");
if isfile(ikFileName)
    warning("Overwriting existing kinematics file.")
    delete(ikFileName);
end
writeToSto(coordinateNames, (1 : size(lhsKinematics, 1)) * 1e-3, ...
    lhsKinematics, ikFileName);
