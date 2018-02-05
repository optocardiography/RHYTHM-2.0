%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.
% Signal conditioning function for signal drift removal
% new_data = remove_Drfit(data,bg) removes the temporal drift from a pixel
% in the cmos data by estimating and substracting a nth degree polynomial
 
% INPUTS
% data = cmos data (voltage, calcium, etc.) from the micam ultima system.
% ord_str = polynomial order for drift removal

% OUTPUT
% new_data = cmos data that has the temporal drift removed

% METHOD
% This function uses polyfit to estimate a polynomial of degree = 4 to fit
% an individual pixel. The polynomial is then subtracted from the temporal
% signal to remove drift. This process is repeated for each pixel in the 100
% X 100 pixel array.  

% REFERENCES
% V.S. Chouhan, S.S. Mehta. Total Removal of Baseline Drift from ECG Signal.
% Proceedings of the International Conference on Computing: Theory and Applications (ICCTA'07)

% ADDITIONAL NOTES
% This code is a bit sluggish.  To improve efficiency, I use the effects of
% remove_BKGRD to my advantage and only try to remove drift from pixels
% still containing signal (non-zero pixels). At some point, I hope Matlab
% comes up with a parallel solution for polyfit.

% RELEASE VERSION 1.0.0

% AUTHOR: Jacob Laughner (jacoblaughner@gmail.com)
%% Code
function new_data = remove_Drift(data,ord_str)
tempx = 1:size(data,3);
tempy = reshape(data,size(data,1)*size(data,2),[]);
temp_ord = ord_str{1};
ord = str2num(temp_ord(1));
for i = 1:size(data,1)*size(data,2)
    if sum(tempy(i,:)) ~= 0
    [p,s,mu] = polyfit(tempx,tempy(i,:),ord);
    y_poly = polyval(p,tempx,s,mu);
    tempy(i,:) = tempy(i,:) - y_poly;
    end
end
new_data = reshape(tempy,size(data,1),size(data,2),size(data,3));