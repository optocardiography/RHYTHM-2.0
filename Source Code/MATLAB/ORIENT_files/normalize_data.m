%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%Normalizes CMOS data between 0 and 1

% INPUTS
% data = cmos data
% Fs = sampling frequency

% OUTPUT
% normData = normalized data matrix

% METHOD
% Normalize data finds the minimum, maximum, and the difference in
% data values. The normalized data subtracts off the minimum values and 
% divides by the difference between the min and max. 

%% Code
function normData = normalize_data(data)
if size(data,3) == 1
    min_data = repmat(min(data,[],2),[1 size(data,2)]);
    diff_data = repmat(max(data,[],2)-min(data,[],2),[1 size(data,2)]);
    normData = (data-min_data)./(diff_data);
else
    min_data = repmat(min(data,[],3),[1 1 size(data,3)]);
    diff_data = repmat(max(data,[],3)-min(data,[],3),[1 1 size(data,3)]);
    normData = (data-min_data)./(diff_data);
end
% % %% NON RECTANGULAR POLYGON MOD
% % min_data = repmat(min(data,[],2),[1 size(data,2)]);
% % diff_data = repmat(max(data,[],2),[1 size(data,2)])-min_data;
% % normData = (data-min_data)./diff_data;