

raw_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_raw';
target_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\testing';

opts = struct('verbose', true, 'downsample', 0.5, 'shift',...
    [40960 30720 0], 'scale_factor', 0.00001, 'same_dir', true,...
    'save_mats', true);

folder  = dir(raw_neurons);

% I'm sure there is a better way to ignore hidden in Matlab but here is 
% my sloppy way
if folder(1).name == '.'
    folder  = folder(2:end);
end
if folder(1).name == '..'
    folder  = folder(2:end);
end

cell_ids = {folder(:).name};

times  = zeros(length(cell_ids),1);
for i = 1:length(cell_ids(1:1))
    times(i) = process_neuron(char(cell_ids(i)),raw_neurons, target_neurons, opts);
end
