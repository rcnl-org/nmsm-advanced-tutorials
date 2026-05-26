close all
import org.opensim.modeling.*
params = getPlottingParams();

% Fill out this variable with your right and left MTP results directories.
mtpResultsDirectory = fullfile("..", "MuscleTendonPersonalization", "MTPResultsLeftFinal");

emgFile = fullfile(mtpResultsDirectory, "muscleActivations", "gait_1_muscleActivations.sto");

[muscleNames, time, muscleActivations] = parseMotToComponents(Model(), Storage(emgFile));

tileFigure = createFigure(muscleNames, params);

for i = 1 : numel(muscleNames)
    nexttile(i)
    plot(time, muscleActivations(i, :), linewidth=2, color=params.lineColors(1))
    title(muscleNames(i))
    ylim([0 1])
    xlim("tight")
end

for k = 3 : 5
    [synergyWeights, synergyActivations] = nnmf(muscleActivations, k);
    reconstructedActivations = synergyWeights * synergyActivations;
    rng(42)
    vaf = calcPercentVaf(muscleActivations, reconstructedActivations);
    fprintf("%d Synergies: %0.2f%% VAF\n", k, vaf);
    for i = 1 : numel(muscleNames)
        nexttile(i)
        hold on
        plot(time, reconstructedActivations(i, :), linewidth=2, color=params.lineColors(k-1))
    end
end
nexttile(1)
legend("Experimental", "3 Synergies", "4 Synergies", "5 Synergies")




function percentVaf = calcPercentVaf(experimental, reconstructed)
sr = sum((experimental - reconstructed) .^ 2);
st = sum(experimental .^ 2);

percentVaf = (1 - sr/st) * 100;
end

function tileFigure = createFigure(labels, params)
figureWidth = ceil(sqrt(numel(labels)));
figureHeight = ceil(numel(labels)/figureWidth);
figure(Units=params.units, Position=params.figureSize)
tileFigure = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');

end