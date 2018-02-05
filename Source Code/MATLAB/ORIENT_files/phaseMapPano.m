%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%% Hilbert Transform Generated Phase Map
%
% INPUTS
% data = cmos data
% starttime = start time of viewing window
% endtime = end time of viewing window
% Fs = sampling frequency
% cmap = colormap (inverted/not inverted)
%
% OUTPUT
% A figure that has a color repersentation for phase
%
% REFERENCES
% None
%
% ADDITIONAL NOTES
% None
%
% RELEASE VERSION: 2014b v1.0
%
% AUTHOR: Jake Laughner
%

function [phase,phaseGeo] = phaseMapPano(data,dataGeo,starttime,endtime,Fs)
%% Code %%
% Calculate Hilbert Transform for 2D images
for n = 1:4
    if size(data{n},3) == 1
        %     data = data(:,round(starttime*Fs+1):round(endtime*Fs+1));
        temp = reshape(data{n},[],size(data{n},2)) - repmat(mean(reshape(data{n},[],size(data{n},2)),2),[1 size(data{n},2)]);
        hdata = hilbert(temp');
        phase = -1*angle(hdata)';
    else
        data{n} = data{n}(:,:,round(starttime*Fs)+1:round(endtime*Fs)+1);
        temp = reshape(data{n},[],size(data{n},3)) - repmat(mean(reshape(data{n},[],size(data{n},3)),2),[1 size(data{n},3)]);
        hdata = hilbert(temp');
        phase{n} = -1*angle(hdata)';
        phase{n} = reshape(phase{n},size(data{n},1),size(data{n},2),[]);
    end
end
% Calculate Hilbert Transform for 3D geometry
%temp = reshape(data{n},[],size(data{n},2)) - repmat(mean(reshape(data{n},[],size(data{n},2)),2),[1 size(data{n},2)]);
temp = dataGeo - repmat(mean(dataGeo,2),[1,size(dataGeo,2)]);
hdata = hilbert(temp');
phaseGeo = -1*angle(hdata)';
end