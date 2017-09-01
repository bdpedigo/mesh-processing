function [tris, verts] = get_tris_and_verts2(file_name)
    fileID = fopen(file_name);

    num_verts = fread(fileID,1,'uint32');

    verts = fread(fileID, [3, num_verts], 'single')';

    tris = fread(fileID, 'uint32');
    fclose(fileID);

    num_tris = length(tris)/3;
    tris = reshape(tris, [3, num_tris])';
    tris = tris + 1;

end