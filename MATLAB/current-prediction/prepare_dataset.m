%% PREPARE DATASET

% This must be expanded
currentList = [0 50e-3 100e-3];

% dataset variables initialization
features = [];
labels = [];

for current = currentList
   current_str = sprintf('%1.3f',current);
   % First of all we compose the filename to load the signatures
   data_file = strcat(current_str,'_signatures.mat');
   % We load the file
   load(data_file);
   % We stack the current data_file to the already loaded features
   features = vertcat(features, signatures);
   labels = vertcat(labels,repmat(current, size(signatures,1),1));
end

dataset = horzcat(features, labels);

dataset2 = minmaxnorm(dataset);