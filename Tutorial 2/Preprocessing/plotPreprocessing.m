close all
plotTreatmentOptimizationJointAngles("..\UF_Subject_4_Scaled_JMP.osim", ...
    "preprocessed\IKData\gait_1.sto", [])
plotTreatmentOptimizationJointLoads("preprocessed\IDData\gait_1.sto", [])
plotTreatmentOptimizationGroundReactions("preprocessed\GRFData\gait_1.sto", [])
plotTreatmentOptimizationMuscleActivations("preprocessed\EMGData\gait_1.sto", [])