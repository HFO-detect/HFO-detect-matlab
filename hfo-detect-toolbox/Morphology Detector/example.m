clear all;close all

load data_example
exampleYes = 1;
[results] = RUN_MorphologyDetector(data,exampleYes);

% additional visuallization fo detected events, detected events are marked in RED
func_PlotResults( results, 2000)
