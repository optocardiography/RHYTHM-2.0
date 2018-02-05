%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: This function loads the data from a VTK generated mesh into
% the workspace. Taken from Dr. Matthew Kay's original code.
%
% Inputs: none
%
% Outputs:
% pts = locations of all the vertices in the mesh
% numparams = ?
% txtparams = ?
% cells = indices of the vertices for each face
% centroids = locations of the centroids of each face
% norms = the normals at each face centroid
% neighs = the indices of the neighboring faces for each face
% neighnum = the number of neighbors each face has
%

function [pts,numparams,txtparams,cells,centroids,norms,...
    neighs,neighnum] = loadVTKmesh()
%% CODE %%
% Grab the current directory
current_dir = pwd;
% Select the desired VTK output
[geoName,geoPath] = uigetfile('*.vtk','Select the VTK output');
geoName = geoName(1:end-8);
% Load associated geometric into handles variables
[centroids,~,~]=readdat([geoPath geoName 'centroids.dat']);
[norms,~,~]=readdat([geoPath geoName 'normals.dat']);
[neighnum,neighs,~,~]=readneighs([geoPath geoName 'neighs.dat']);   % 2/23/05 MWKay
% neighs is a structure
[pts,numparams,txtparams]=readdat([geoPath geoName 'pts.dat']);
[cells,~,~]=readdat([geoPath geoName 'cells.dat']);
cells=cells+ones(size(cells));   % VTK starts with zero, matlab starts with one
for i=1:size(cells,1)            % VTK starts with zero, matlab starts with one
    for j=1:neighnum(i)
        neighs{i}(j)=neighs{i}(j)+1;
    end
end
% Return to the original directory
cd(current_dir)
end