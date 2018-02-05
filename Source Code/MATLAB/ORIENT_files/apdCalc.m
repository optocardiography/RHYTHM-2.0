%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

% The function [actC] = apdCalc() calculates the mean APD and the standard
%deviation in the area selected. 
% 
%INPUTS
%data= cmosdata(voltage,etc)
%start=windowed start time
%endp=windowed end time
%Fs=sampling frequency
%percent=percent repolarization 
%maxAPD=maximum apd allowed
%minAPD=minimum apd allowed
%motion=boolean statement to allow motion to be removed
%coordinate=coordinates from selected box
%bg=background image
%
% OUTPUT
% A figure that has a color repersentation for action potential duration
% times that you selected. Mean and standard deviation APD in selected 
%region 

% METHOD
%We use the the maximum derivative of the upstroke as the initial point of
%activation. The time of repolarization is determine by finding the time 
%at which the maximum of the signal falls to the desired percentage. APD is
%the difference between the two time points. 

% REFERENCES
%None

% ADDITIONAL NOTES
% None

% RELEASE VERSION 1.0.0

% AUTHOR: Matt Sulkin (sulkin.matt@gmail.com)

function [apdC] = apdCalc(data,start,endp,Fs,percent,maxAPD,minAPD,motion,coordinate,bg,cmap)
%% Create initial variablesns
start=round(start*Fs);
endp=round(endp*Fs);
coordinate=round(coordinate);
 
%Use data only in your window
apd_data = data(coordinate(2):coordinate(2)+coordinate(4),coordinate(1):coordinate(1)+coordinate(3),start:endp);
apd_data = normalize_data(apd_data); %re-normalize windowed data


% %REMOVE MOTION
%remove motion with peak finder 
%makes an matrix of 10000 x the number of frames
if motion==1
    apd_data=reshape(apd_data,(coordinate(3)+1)*(coordinate(4)+1),[]);
    for  i=1:coordinate(3)*coordinate(4)
        [~,location] = findpeaks(apd_data(i,:), 'minpeakheight', .7);
        if length(location)>1
            apd_data(i,:)=nan;
        end
    end
    apd_data=reshape(apd_data,coordinate(3)+1,coordinate(4)+1,[])';
end

%%Determining activation time point
% Find First Derivative and time of maximum
apd_data2 = diff(apd_data,1,3); % first derivative
[~,max_i] = max(apd_data2,[],3); % find location of max derivative


%%Find location of repolarization
%%Find maximum of the signal 
[~,maxValI] = max(apd_data,[],3);

%locs is a temporary holding place
locs = zeros(size(apd_data,1),size(apd_data,2));

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
apdMap = apd * unitFix;
apdMap(apdMap <= 0) = nan;

%remove APD that are out of imput values
apdMap(apdMap>maxAPD) = nan;
apdMap(apdMap<minAPD) = nan; 

% %calculating mean and std
apd_mean=nanmean(apdMap(:));
disp(['The average APD in the region is ' num2str(apd_mean) '.'])
apd_std=nanstd(apdMap(:));
disp(['The standard deviation of APDs in the region is ' num2str(apd_std) '.'])
apd_median=nanmedian(apdMap(:));
disp(['The median APD in the region is ' num2str(apd_median) '.'])

%Setting up values to use for color axis
APD_min = mean(apdMap(isfinite(apdMap))) - 2*std(apdMap(isfinite(apdMap)));
APD_max = mean(apdMap(isfinite(apdMap))) + 2*std(apdMap(isfinite(apdMap)));

% Plot APDMap
figure('Name','APD Map');

% Create Mask
actMap_Mask=zeros(size(bg));
actMap_Mask(coordinate(2):coordinate(2)+coordinate(4),coordinate(1):coordinate(1)+coordinate(3))=1;

actMap_Mask2=zeros(size(bg));
actMap_Mask2(coordinate(2):coordinate(2)+coordinate(4),coordinate(1):coordinate(1)+coordinate(3))=apdMap;
%Build Image
G =real2rgb(bg, 'gray');
J=real2rgb(actMap_Mask2,cmap,[APD_min APD_max]);
A=real2rgb(actMap_Mask,'gray');

I = J .* A + G .* (1-A);

subplot(1,2,1)
image(I)
colormap(cmap)
axis image
set(gca,'XTick',[],'YTick',[],'Xlim',[0 size(data,1)],'YLim',[0 size(data,2)])
subplot(1,2,2)
imagesc(apdMap)
colormap(cmap)
axis image
colorbar
caxis([APD_min APD_max])
figure('Name','Histogram of APD')
hist(reshape(apdMap,[],1),floor(APD_max-APD_min)*2)


apdC = apdMap;

end