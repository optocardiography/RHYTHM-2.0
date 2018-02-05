%% Get Calibration Information
%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Description: File for aggregating the calibration point locations for the
% geometric camera and the optical cameras.
%
% Inputs:
% CalibType = (1) indicates calibration of geometric camera, (2) CMOS
% camera A, (3) CMOS camera B, (4) CMOS camera C, (5) CMOS camera D
%
% Outputs:
% plane1fname = locations of calibration points right face of block
% plane2fname = locations of calibration points left face of block
%

%% Code %%
function [plane1fname,plane2fname] = getCalibInfo(calibType)
% Preallocate variables
plane1fname = [];
plane2fname = [];

% Populate variables
% Geometry camera and CMOS camera A    
if calibType == 1 || calibType == 2
    % plane 1 calibration filenames
    plane1fname = 'calpts2_negY.txt';
    % plane 2 calibration files
    plane2fname = 'calpts2_negX.txt';
% CMOS camera B    
elseif calibType == 3
    % plane 1 calibration filenames
    plane1fname = 'calpts2_negX.txt';
    % plane 2 calibration files
    plane2fname = 'calpts2_posY.txt';
% CMOS camera C        
elseif calibType == 4
    % plane 1 calibration filenames
    plane1fname = 'calpts2_posY.txt';
    % plane 2 calibration files
    plane2fname = 'calpts2_posX.txt';
% CMOS camera D    
elseif calibType == 5
    % plane 1 calibration filenames
    plane1fname = 'calpts2_posX.txt';
    % plane 2 calibration files
    plane2fname = 'calpts2_negY.txt';
end

end