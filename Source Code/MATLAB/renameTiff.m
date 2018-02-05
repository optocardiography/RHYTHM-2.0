%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: Rename first 9 images to add leading 0

function renameTiff(~,~)
[filename,dir] = uigetfile('*.*','Pick the First Picture!');
cd(dir);
for n=1:1:9
    filetag = filename(1:size(filename,2)-6);
    tmp = sprintf('a = imread(''%s%d.tiff'');',filetag, n);
    eval(tmp)
    tmp = sprintf('imwrite(a, ''%s0%d.tiff'');',filetag,n);
    eval(tmp)
    tmp = sprintf('delete(''%s%d.tiff'');',filetag, n);
    eval(tmp)
end