# mesh-processing
Short scripts and functions for reading in binary meshes, downsampling if necessary, and exporting as .stl 

'get_tris_and_verts()' is used to read in the binary data from a single chunk. 

'process_neuron()' calls 'get_tris_and_verts()' on every chunk in a specfied folder. It makes no attempt to check whether all
these chunks belong to the manifest file also stored in each folder. It then combines all of these chunks into one unified 
mesh. This mesh can be saved as Matlab variables, a Matlab patch figure, or as an stl using Sven's stlwrite() function
available here https://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-filename--varargin- or in the util folder.

'process_neurons_from_folder()' is an example of how 'process_neuron()' can be used to loop over many cells. 

The mesh binary format is explained here:
https://github.com/seung-lab/neuroglancer/wiki/Precomputed-API#mesh-representation-of-segmented-object-surfaces
