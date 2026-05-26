close all

plotGroundReactions(fullfile("..", "InputData", "Trial10_forces_ec_reordered_filtered.mot"), [], ...
    columnNames = ["Left Foot X Force", "Left Foot Y Force", "Left Foot Z Force", ...
    "Left Foot X Moment", "Left Foot Y Moment", "Left Foot Z Moment", ...
    "Right Foot X Force", "Right Foot Y Force", "Right Foot Z Force", ...
    "Right Foot X Moment", "Right Foot Y Moment", "Right Foot Z Moment"])

function plotGroundReactions(trackedDataFile, resultsDataFiles, varargin)
import org.opensim.modeling.Model
params = getPlottingParams();
if ~isempty(varargin)
    options = parseVarargin(varargin);
else
    options = struct();
end
if isfield(options, "showRmse")
    showRmse = options.showRmse;
else
    showRmse = 1;
end

model = org.opensim.modeling.Model();
[tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model);
% Tracked and results files can have columns in different order sometimes.
[tracked, results] = sortGroundReactionData(tracked, results);
tracked = resampleTrackedData(tracked, results);
yLimits = makeGroundReactionsYLimits(tracked, results);

% Allow only plot certain column names from the input files
if isfield(options, "columnsToUse")
    [~, ~, trackedIndices] = intersect(options.columnsToUse, tracked.labels, "stable");
    tracked.data = tracked.data(:, trackedIndices); 
    tracked.labels = tracked.labels(trackedIndices);
    for j = 1 : numel(resultsDataFiles)
        [~, ~, resultsIndices] = intersect(options.columnsToUse, results.labels{j}, "stable");
        results.data{j} = results.data{j}(:, resultsIndices); 
        results.labels{j} = results.labels{j}(resultsIndices);
    end
    yLimits = yLimits(trackedIndices);
end

% Allow renaming columns in the subplot titles
if isfield(options, "columnNames")
    tracked.labels = options.columnNames;
    for j = 1 : numel(resultsDataFiles)
        results.labels{j} = options.columnNames;
    end
end

tileFigure = makeGroundReactionsFigure(params, options);
figureSize = tileFigure.GridSize(1)*tileFigure.GridSize(2);
subplotNumber = 1;
titleStrings = makeGroundReactionsSubplotTitles(tracked, results, showRmse);
 
if isfield(options, "legend")
    legendString = options.legend;
else
    legendString = makeLegendFromFileNames(trackedDataFile, ...
                resultsDataFiles);
end

for i=1:numel(tracked.labels)
    if subplotNumber > figureSize
        tileFigure = makeGroundReactionsFigure(params, options);
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(tracked.time, tracked.data(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1))
    hold off

    title(titleStrings{i}, fontsize = params.subplotTitleFontSize, ...
            Interpreter="none")
    if subplotNumber==figureSize || i == numel(tracked.labels)
        legend(legendString, fontsize = params.legendFontSize, ...
            Interpreter="none")
    end
    xlim("tight")
    ylim(yLimits{i});
    subplotNumber = subplotNumber + 1;
end
end

function options = parseVarargin(varargin)
    options = struct();
    varargin = varargin{1};
    for k = 1 : 2 : numel(varargin)
        options.(varargin{k}) = varargin{k+1};
    end
end

function [tracked, results] = sortGroundReactionData(tracked, results)
% Sort results ground reactions to be in the same order as the tracked
% ground reactions. Also removes the point columns
pointIndices = contains(tracked.labels, "_p");
tracked.labels = tracked.labels(~pointIndices);
tracked.data = tracked.data(:, ~pointIndices);
for j = 1 : numel(results.data)
    [~, ~, indices] = intersect(tracked.labels, results.labels{j}, "stable");
    results.data{j} = results.data{j}(:,indices);
    results.labels{j} = results.labels{j}(indices);
end
end

function titleStrings = makeGroundReactionsSubplotTitles(tracked, results, showRmse)
for i = 1 : numel(tracked.labels)
    titleStrings{i} = [sprintf("%s", strrep(tracked.labels(i), "_", " "))];
    if showRmse
        for j = 1 : numel(results.data)
            rmse = rms(tracked.resampledData{j}(1:end-1, i) - ...
                results.data{j}(1:end-1, i));
            titleStrings{i}(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
        end
    end
end
end

function tileFigure = makeGroundReactionsFigure(params, options)
if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = 3;
    figureHeight = 2;
end
figure(Name = "Ground Reactions", ...
    Units=params.units, ...
    Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(tileFigure, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(tileFigure, "Ground Reaction", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
end

function yLimits = makeGroundReactionsYLimits(tracked, results)
for i = 1 : numel(tracked.labels)
    maxData = [];
    minData = [];
    maxData(1) = max(tracked.data(1:end-1, i), [], "all");
    minData(1) = min(tracked.data(1:end-1, i), [], "all");
    for j = 1 : numel(results.data)
        maxData(j+1) = max(results.data{j}(1:end-1, i), [], "all");
        minData(j+1) = min(results.data{j}(1:end-1, i), [], "all");
    end
    yLimits{i} = [min(minData), max(maxData)];
end
end

function [tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model)
    import org.opensim.modeling.*
    if nargin < 3
        model = org.opensim.modeling.Model();
    end
    tracked = struct();
    results = struct();
    tracked.dataFile = trackedDataFile;
    results.dataFiles = resultsDataFiles;
    trackedDataStorage = Storage(trackedDataFile);
    [tracked.labels, tracked.time, tracked.data] = parseMotToComponents(...
        model, trackedDataStorage);
    tracked.data = tracked.data';
    % We want time points to start at zero.
    if tracked.time(1) ~= 0
        tracked.time = tracked.time - tracked.time(1);
    end
    tracked.normalizedTime = tracked.time / tracked.time(end);
    results.data = {};
    results.labels = {};
    results.time = {};
    for j=1:numel(resultsDataFiles)
        resultsDataStorage = Storage(resultsDataFiles(j));
        [results.labels{j}, results.time{j}, results.data{j}] = parseMotToComponents(...
            model, resultsDataStorage);
        results.data{j} = results.data{j}';
        if results.time{j} ~= 0
            results.time{j} = results.time{j} - results.time{j}(1);
        end
        results.normalizedTime{j} = results.time{j} / results.time{j}(end);
    end
end

function tracked = resampleTrackedData(tracked, results)
    trackedDataSpline = makeGcvSplineSet(tracked.time, ...
        tracked.data, tracked.labels);
    for j = 1 : numel(results.data)
        tracked.resampledData{j} = evaluateGcvSplines(trackedDataSpline, ...
            tracked.labels, results.time{j});
    end
end

function legendString = makeLegendFromFileNames(trackedDataFile, resultsDataFiles)
[directory, fileName, ~] = fileparts(trackedDataFile);
directoryFolderNames = split(directory, ["/", "\"]);
topFolderName = directoryFolderNames(end);
if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
    topFolderName = directoryFolderNames(end-1);
end
legendString = sprintf("%s (T)", topFolderName);
% Logic to change the legend if using the replaced experimental ground
% reactions file because in that case, the legend labels will be the same
% for both lines.
if contains(fileName, "replacedExperimentalGroundReactions")
    legendString = sprintf("%s (T)", fileName);
end
for j = 1 : numel(resultsDataFiles)
    [directory, ~, ~] = fileparts(resultsDataFiles(j));
    directoryFolderNames = split(directory, ["/", "\"]);
    topFolderName = directoryFolderNames(end);
    if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
        topFolderName = directoryFolderNames(end-1);
    end
    legendString(j+1) = sprintf("%s (%d)", topFolderName, j);
end
end