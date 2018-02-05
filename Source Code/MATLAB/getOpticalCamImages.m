%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: Grabs optical images from optical data files.

function getOpticalCamImages(~,~)
% Choose GSD or GSH file to pick optical images
[filename,path] = uigetfile('*.*','Pick Optical File To Get Pics');
cd(path);
label = 'ABCD';
if filename ~= 0
    filetag = filename(1:size(filename,2)-5);
    % Select directory to save iamges in
    dir_name = uigetdir('Save Image in');
    for n = 1:4
        CMOSconverter(path,strcat(filetag,label(n),'.gsh'));
        data = load(strcat(filetag,label(n),'.mat'));
        a = real2rgb(data.bgimage,'gray');
        % Save images
        imwrite(a, strcat(dir_name,'/cube',label(n),'.tiff'));
    end
end
end