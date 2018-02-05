%% Email optocardiography@gmail.com for any questions or concerns.
%% Refer to efimovlab.org for more information.

function maxf = calDomFreqPano(data,Fs)

maxf = cell(1,length(data));
for k = 1:length(data)
    %% Window Data with Tukey Window to Minimize Edge Effects
    if size(data{k},3) == 1
        w_m = tukeywin(size(data{k},2),.05);
        win = repmat(w_m',[size(data{k},1) 1]);
    else
        w_m = tukeywin(size(data{k},3),.05);
        win = repmat(permute(w_m,[3 2 1]),[size(data{k},1),size(data{k},2)]);
    end
    data{k} = data{k}.*win;
    %% Find single-sided power spectrum of data
    if size(data{k},3) == 1
        m = size(data{k},2);           % Window length
        n = pow2(nextpow2(m));      % Transform Length
        y = fft(data{k},n,2);          % DFT of signal
    else
        m = size(data{k},3);           % Window length
        n = pow2(nextpow2(m));      % Transform Length
        y = fft(data{k},n,3);          % DFT of signal
    end
    f = Fs/2*linspace(0,1,n/2+1);   % Frequency range
    p = y.*conj(y)/n;               % Power of the DFT
    if size(data{k},3) == 1
        p_s = 2*abs(p(:,1:n/2+1));      % Single-sided power
        p_s(:,1) = [];                % Remove DC component
    else
        p_s = 2*abs(p(:,:,1:n/2+1));    % Single-sided power
        p_s(:,:,1) = [];                % Remove DC component
    end
    f(1) = [];                      % Remove DC
    
    %% Find Dominant Frequency
    if size(data{k},3) == 1
        [val,ind] = max(p_s,[],2);
        maxf{k} = f(ind).*isfinite(val)';
    else
        [val,ind] = max(p_s,[],3);
        maxf{k} = f(ind).*isfinite(val);
    end

end
end