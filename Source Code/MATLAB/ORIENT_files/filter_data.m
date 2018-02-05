%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

%% The filter function applies a finite impulse response signal processing
%  filter to the data using the Parks-McClellan Remez Exchange Algorithm

% INPUTS
% data = cmos data
% Fs = sampling frequency
% or = order of filter
% lb = low passband threshold frequency (typically 0Hz)
% hb = high passband threshold frequency

% OUTPUT
% filt_data = data with FIR filter applied

% METHOD
% Filt uses a filter with an impulse response of finite
% duration. Rhythm.m provides different options with regard to the order of
% the filter and the low and high passband threshold frequencies.
% The code for a Butterworth filter and Chebyshev II filter, with infinite impulse response, is also provided.

function filt_data = filter_data(data,Fs,or,lb,hb)
    %% FIR filter
    % FIR filter implemented with Parks-McClellan Remez Exchange Algorithm
    tic
    a0 = [1 1 0 0];
    f0 = [0 hb hb*1.25 Fs/2]./(Fs/2);
    b = firpm(or,f0,a0);
    a = 1;
    %% IIR filter
%      Wn = hb/(Fs/2); % Pass band for low pass filter
%     [b,a] = butter(5,Wn); % Example of Butterworth Filter
%     [b,a] = cheby2(15,20,Wn); % Example of ChebyII Filter

    %% Apply Filter
    temp = reshape(data,[],size(data,3));
    filt_temp = zeros(size(temp));
    for i = 1:size(temp,1)
        if sum(temp(i,:)) ~= 0
        filt_temp(i,:) = filtfilt(b,a,temp(i,:)); % needed to create 0 phase offset
        end
    end
    filt_data = reshape(filt_temp,size(data,1),size(data,2),[]);