function time = process_neuron(neuron_id, raw_neurons, target_neurons, opts)
%{
Takes in the ID for a cell (or other object in the EM volume) and creates a
mesh representation of the object from the corresponding binary files. The
binary files come from raw_neurons, and the mesh (in several
representations) are saved to target_neurons. 
Options described below. 

Parameters
----------
neuron_id : str/char
raw_neurons : str/char
    Directory where neuron chunks are stored. Expects this dir to have a 
    folder named neuron_id in it.
target_neurons : str/char
    Wherever you want to save everything. If using same_dir, all outputs
    will be dumped into the same dir. Otherwise, it will create folders 
    for each neuron_id

Options (opts struct)
---------------------
verbose : bool 
downsample : float/int
    Must be in range (0, 1]. downsample = 0.5 would give you a new mesh
    with half as many faces
shift : array
    Must be 1 x 3, corresponds to (x,y,z). Use [0 0 0] if you want no 
    shifting. This will be subtracted from every vertex 
scale factor : float 
    AFTER SHIFTING, scales the value of every vertex
same_dir : bool 
    True if you want to put all output into the same folder, False for each
    cell's output in its own. Will make the subfolders for you.
save_mats : bool
    True if you want to save outputs in Matlab formats


Notes:
-Does not currently check the manifest file to make sure that all of the
chunks are being incorporated into the full mesh.
-Downsampling is not ideal right now, tends to distort axons and dendrites
especially (any relatively small structure). The full stls can usually be
opened one at a time (at least on my computer).
-shift is applied BEFORE scale 

Input examples:
neuron_id = '3456768'

raw_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_raw\';
target_neurons = 'Z:\ben\20170818_fixed_bug\';

%}

%%% options %%%
verbose = opts.verbose; 
downsample = opts.downsample;
shift = opts.shift; % [40960 30720 0]
scale_factor = opts.scale_factor; % 0.00001
same_dir = opts.same_dir;
save_mats = opts.save_mats;

%%%%%%%%%%%%%%%%%%%

tic 

neuron_id_= strcat(neuron_id, '_0');

neuron_dir_raw = strcat(raw_neurons, '\', neuron_id);

if same_dir
    neuron_dir_target = strcat(target_neurons, '\'); 
else
    neuron_dir_target = strcat(target_neurons, neuron_id);
    [status msg msgID] = mkdir(neuron_dir_target);
end

addpath(neuron_dir_raw);
files = dir(neuron_dir_raw);

neuron_verts = [];
neuron_tris = [];

if verbose, disp('Loading neuron binary...'); end 

neuron_tris = cell(length(files),1);
neuron_verts = cell(length(files),1);

parfor i = 1:length(files)
   if files(i).isdir || strcmp(files(i).name, neuron_id_)
      continue 
   end
    
   [tris, verts] = get_tris_and_verts(files(i).name);

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

% Checking for an empty cell so we don't make an empty mesh
if length(neuron_tris) == 0 | length(neuron_verts) == 0
   time = toc
   disp(['Broke on empty cell ', neuron_id])
   return
end

% Removing duplicates
[neuron_verts, indm, indn] = unique(neuron_verts, 'rows');
neuron_tris = indn(neuron_tris);

% Shifting and downsizing
neuron_verts = neuron_verts - shift;
neuron_verts = neuron_verts * scale_factor;

% Save the raw Matlab variables if you want 
if save_mats
    neuron_tris_savename = strcat(neuron_dir_target, '\', neuron_id,'_tris.mat');
    neuron_verts_savename = strcat(neuron_dir_target, '\', neuron_id,'_verts.mat');
    save(neuron_tris_savename, 'neuron_tris');
    save(neuron_verts_savename, 'neuron_verts');
end

neuron_stl_savename = strcat(neuron_dir_target, '\', neuron_id, '.stl');
stlwrite(neuron_stl_savename, neuron_tris,neuron_verts);

if downsample ~= 1
    if verbose, disp('Downsampling...'); end 
    neuron_patch_downsample = reducepatch(neuron_tris, neuron_verts,...
        downsample, 'fast');
    
    if save_mats
        neuron_patch_downsample_savename = strcat(neuron_dir_target, '\',...
            neuron_id, '_ds', num2str(1/downsample), '.mat');
        save(neuron_patch_downsample_savename, 'neuron_patch_downsample');
    end
    
    if verbose, disp('Writing downsampled .stl...'); end 

    neuron_stl_downsample_savename = strcat(neuron_dir_target, '\',...
        neuron_id, '_ds', num2str(1/downsample), '.stl');
    stlwrite(neuron_stl_downsample_savename, neuron_patch_downsample);
   
    % also save downsampled as a Matlab 'patch' figure
    if save_mats
        if verbose, disp('Saving as Matlab .fig...'), disp(''); end
        f = figure('visible', 'off');
        axis equal
        patch(neuron_patch_downsample);
        set(f, 'Visible', 'on');
        figure_d100_filename = strcat(neuron_dir_target, '\', neuron_id,...
            '_fig_ds', num2str(1/downsample));
        saveas(f, figure_d100_filename, 'fig'); 
        delete(f);
    end
end

if verbose
    ms = ['Done with neuron ', neuron_id];
    disp(ms)
end 
time = toc;
end






