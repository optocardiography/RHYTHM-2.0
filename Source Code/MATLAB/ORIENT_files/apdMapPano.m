%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% Creates a visual representation of the action potential duration 
%
% INPUTS
% data=cmos data
% start=start time
% endp=end time
% Fs=sampling frequency
% percent=percent repolarization
%
% OUTPUT
% A figure that has a color repersentation for action potential duration
% times
%
% METHOD
% We use the the maximum derivative of the upstroke as the initial point of
% activation. The time of repolarization is determine by finding the time 
% at which the maximum of the signal falls to the desired percentage. APD is
% the difference between the two time points. 
%
% REFERENCES
% None
%
% ADDITIONAL NOTES
% None
%
% RELEASE VERSION 1.0.0
%
% AUTHOR: Matt Sulkin (sulkin.matt@gmail.com)
%

function [apdMap] = apdMapPano(data,start,endp,Fs,percent)
%% Create initial variables
start=round(start*Fs)+1;
endp=round(endp*Fs)+1;
% Code not used in current version %
apdMap = cell(5,1);

for n = 1:4
    apd_data = data{n}(:,:,start:endp);        % window signal
    apd_data = normalize_data(apd_data); %re-normalize windowed data
    
    %%Determining activation time point
    % Find First Derivative and its index of maximum
    apd_data2 = diff(apd_data,1,3); % first derivative
    [~,max_i] = max(apd_data2,[],3); % find location of max derivative
    
    
    %%Find location of repolarization
    %%Find maximum of the signal and its index
    [~,maxValI] = max(apd_data,[],3);
    
    %locs is a temporary holding place
    locs = nan(size(apd_data,1),size(apd_data,2));
    
    %Define the baseline value you want to go down to
    requiredVal = 1.0 - percent;
    
    %%for each pixel
    for i = 1:size(apd_data,1)
        for j = 1:size(apd_data,2)
            %%starting from the peak of the signal, loop until we reach baseline
            for k = maxValI(i,j):size(apd_data,3)
                if apd_data(i,j,k) <= requiredVal
                    locs(i,j) = k; %Save the index when the baseline is reached
                    %this is the repolarizatin time point
                    break;
                end
            end
        end
    end
    
    %%account for different sampling frequencies
    unitFix = 1000.0 / Fs;
    
    % Calculate Action Potential Duration
    apd = minus(locs,max_i);
    apdMap{n} = apd * unitFix;
    apdMap{n}(apdMap{n} <= 0) = 0;
end

%% Calculate APD for projected data %%
apd_data = data{5}(:,start:endp);        % window signal
apd_data = normalize_data(apd_data); %re-normalize windowed data

%%Determining activation time point
% Find First Derivative and its index of maximum
apd_data2 = diff(apd_data,1,2); % first derivative
[~,max_i] = max(apd_data2,[],2); % find location of max derivative


%%Find location of repolarization
%%Find maximum of the signal and its index
[~,maxValI] = max(apd_data,[],2);

%locs is a temporary holding place
locs = zeros(size(apd_data,1),1);

%Define the baseline value you want to go down to
requiredVal = 1.0 - percent;

%%for each pixel
for i = 1:size(apd_data,1)
    %%starting from the peak of the signal, loop until we reach baseline
    for j = maxValI(i):size(apd_data,2)
        if apd_data(i,j) <= requiredVal
            locs(i) = j; %Save the index when the baseline is reached
            %this is the repolarizatin time point
            break;
        end
    end
end

%%account for different sampling frequencies
unitFix = 1000.0 / Fs;

% Calculate Action Potential Duration
apd = minus(locs,max_i);
apdMap{5} = apd * unitFix;
apdMap{5}(apdMap{5} <= 0) = 0;

end