close all

plotTreatmentOptimizationJointAngles(...
    fullfile("..", "UF_Subject_4_Scaled_JMP.osim"), ...
    "Trial10_IKResults.mot", [])

plotTreatmentOptimizationJointLoads("Trial10_IDResults.sto", [])

plotTreatmentOptimizationMuscleActivations("Trial10_emg_processed.sto", [])

plotTreatmentOptimizationGroundReactions(...
    "Trial10_forces_ec_reordered_filtered.mot", [])