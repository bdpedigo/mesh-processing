cell = 131506448
raw_neurons = 'C:\Users\benjaminp\Desktop\NeuronReconstructions\20170818_raw';
target_neurons = 'Z:\ben\voxelise';
opts = struct('verbose', true, 'downsample', 1, 'shift',...
    [0, 0, 0], 'scale_factor', 1, 'same_dir', true,...
    'save_mats', true);
%[40960 30720 0]
%%

times = process_neuron(num2str(cell),raw_neurons, target_neurons, opts);
%%
name = strcat(target_neurons, '\', num2str(cell), '_verts.mat');
verts = load(name);
verts = verts.neuron_verts;

name = strcat(target_neurons, '\', num2str(cell), '_tris.mat');
tris = load(name);
tris = tris.neuron_tris;
%%
neuron_patch = patch('Faces',tris, 'Vertices',verts);
%%
var = struct
var.vertices = verts;
var.faces = tris;
x_size = max(var.vertices(:,1)) - min(var.vertices(:,1));
y_size = max(var.vertices(:,2)) - min(var.vertices(:,2));
z_size = max(var.vertices(:,3)) - min(var.vertices(:,3));

x_size = floor(x_size/10)
y_size = floor(y_size/10)
z_size = floor(z_size/10)
%%
binary = VOXELISE(x_size, y_size, z_size, var);

%%
for i=1:size(binary,3)
    filename = strcat(target_neurons,'\', '131506448_binary_', string(i), '.tiff');
    filename = char(filename)
    imwrite(binary(:,:,i), filename, 'tiff');
    
end