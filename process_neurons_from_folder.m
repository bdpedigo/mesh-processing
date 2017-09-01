
% need \ at the end of dirs
raw_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_raw\';
target_neurons = 'Z:\ben\20170818_fixed_bug\';
stl_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_just_dstl2\';

send_text = true;
opts = struct('verbose', true, 'coarse_progress', false, 'send_text', true,'d100', false, 'd10', false, 'shift', [40960 30720 0] , 'reduce_size', true);


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

tic

times  = zeros(length(cell_ids),1);
for i = 1:length(cell_ids)
    times(i) = open_process_neuron_fast_check(char(cell_ids(i)),raw_neurons, target_neurons, stl_neurons, opts);
end

% Timer is broken here but still can notify you when all cells have
% finished
t = toc;
if send_text
    t = secs2hms(t);
    t = strcat(' ', t);
    msg = ['Took ', t, ' to process all neurons '];
    send_msg({'206-458-8138', 'bpedigo.notifier@gmail.com'},'Neuron Reconstructions', msg,'verizon')
end