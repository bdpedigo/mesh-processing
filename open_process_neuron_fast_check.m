function time = open_proces_neuron_fast_check(neuron_id, raw_neurons, target_neurons, target_stls, opts)
%{
Takes in the ID for a cell (or other object in the EM volume) and creates a
mesh representation of the object from the corresponding binary files. The
binary files come from raw_neurons, and the mesh (in several
representations) are saved to target_neurons. The stl files are also saved
(a second time) to target_stls for easy import/working with blender.
Options described below. 

Notes:
-Does not currently check the manifest file to make sure that all of the
chunks are being incorporated into the full mesh.
-Downsampling is not ideal right now, tends to distort axons and dendrites
especially (any relatively small structure). The full stls can usually be
opened one at a time (at least on my computer).

Input examples:
neuron_id = '3456768'

As currently written, the directories below require a \ at the end
raw_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_raw\';
target_neurons = 'Z:\ben\20170818_fixed_bug\';
stl_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_just_dstl2\';


%}

%%% options %%%
send_text = opts.send_text; % send a text message to specified phone #
verbose = opts.verbose; % output data on progress for each cell
d100 = opts.d100; % downsample 100x?
d10 = opts.d10; % downsample 10x?
reduce_size = opts.reduce_size; % reduce size by scale factor?
shift = opts.shift; % [40960 30720 0]
scale_factor = 0.00001;

%%%%%%%%%%%%%%%%%%%

tic 
neuron_id_= strcat(neuron_id, '_0');

neuron_dir_raw = strcat(raw_neurons, neuron_id);
neuron_dir_target = target_neurons;%strcat(target_neurons, neuron_id);
%[status msg msgID] = mkdir(neuron_dir_target);

addpath(neuron_dir_raw);
files = dir(neuron_dir_raw);

neuron_verts = [];
neuron_tris = [];

if verbose, disp('Loading neuron binary'); end 

neuron_tris = cell(length(files),1);
neuron_verts = cell(length(files),1);


parfor i = 1:length(files)
   if files(i).isdir || strcmp(files(i).name, neuron_id_)
      continue 
   end
    
   [tris, verts] = get_tris_and_verts2(files(i).name);

   neuron_tris{i} = tris;
   neuron_verts{i} = verts;

end

% When combining tris into the same data structure, need to update the
% indices they correspond to so that they reference the correct verts
index_length = 0;

for i = 2:length(neuron_tris)
   index_length = index_length + length(neuron_verts{i - 1});
   neuron_tris{i} = neuron_tris{i} + index_length;
end

% Combine data from all chunks
neuron_tris = vertcat(neuron_tris{:});
neuron_verts = vertcat(neuron_verts{:});

% Removing duplicates
[neuron_verts, indm, indn] = unique(neuron_verts, 'rows');
neuron_tris = indn(neuron_tris);

neuron_tris_savename = strcat(neuron_dir_target, '\', neuron_id,'_tris.mat');
neuron_verts_savename = strcat(neuron_dir_target, '\', neuron_id,'_verts.mat');

%save(neuron_tris_savename, 'neuron_tris');
%save(neuron_verts_savename, 'neuron_verts');

% Checking for an empty cell so we don't make an empty mesh
if length(neuron_tris) == 0 | length(neuron_verts) == 0
   time = toc
   disp(['Broke on empty cell ', neuron_id])
   return
end

% Shifting and downsizing
neuron_verts_ss = neuron_verts - shift;
if reduce_size, neuron_verts_ss = neuron_verts_ss .* scale_factor; end

neuron_stl_savename = strcat(neuron_dir_target, '\', neuron_id, '.stl');
stlwrite(neuron_stl_savename, neuron_tris,neuron_verts_ss);

% Never use this one so hasn't been updated
if d10
    if verbose, disp('Downsampling 10x'); end 
    neuron_patch_downsample_10 = reducepatch(neuron_tris, neuron_verts, .1);
    neuron_patch_downsample_10_savename = strcat(neuron_dir_target, '\', neuron_id,'_d10.mat');
    save(neuron_patch_downsample_10_savename, 'neuron_patch_downsample_10');
end

if d100
    if verbose, disp('Downsampling 100x'); end 
    neuron_patch_downsample_100 = reducepatch(neuron_tris, neuron_verts, .01, 'verbose', 'fast');
    neuron_patch_downsample_100_savename = strcat(neuron_dir_target, '\', neuron_id, '_d100.mat');
    save(neuron_patch_downsample_100_savename, 'neuron_patch_downsample_100');
    
    if verbose, disp('Writing 100x Downsample .stl'); end 

    var = neuron_patch_downsample_100;

    var.vertices = var.vertices - shift;
    if reduce_size, var.vertices = var.vertices .* scale_factor; end
    
    neuron_stl_downsample_100_savename = strcat(neuron_dir_target, '\', neuron_id, '_stl_d100.stl');
    neuron_stl_only_savename = strcat(target_stls, neuron_id, '_stl_d100.stl');
    stlwrite(neuron_stl_downsample_100_savename, var);
    stlwrite(neuron_stl_only_savename, var);
    
    if verbose, disp('Saving as Matlab .fig'); end
    f = figure('visible', 'off');
    axis equal
    patch(neuron_patch_downsample_100);
    set(f, 'Visible', 'on');
    figure_d100_filename = strcat(neuron_dir_target, '\', neuron_id, '_fig_d100');
    saveas(f, figure_d100_filename, 'fig'); 
    delete(f);
end

if verbose
    ms = ['Done with neuron ', neuron_id];
    disp(ms)
end 
time = toc;
if send_text
    t = secs2hms(time);
    t = strcat(' ', t);
    msg = ['Took ', t, ' to process neuron ', neuron_id];
    send_msg({'bpedigo.notifier@gmail.com'},'Neuron Reconstruction', msg,'verizon')
end
end






