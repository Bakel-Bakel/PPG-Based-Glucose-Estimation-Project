function PPG_FeaturePipeline()
    % Main function to run full feature extraction pipeline
    rawDataPath = '../PPG_Dataset/RawData';
    labelPath = '../PPG_Dataset/Labels';
    outputPath = 'ML';
    if ~exist(outputPath, 'dir'); mkdir(outputPath); end

    files = dir(fullfile(rawDataPath, '*.mat'));
    fs = 2175;  % Sampling Frequency
    D = 5;      % Downsampling factor

    features = {};

for i = 1:length(files)
    % -------------------------------
    % Load Raw PPG Signal
    % -------------------------------
    file = files(i).name;
    raw = load(fullfile(rawDataPath, file));
    rawField = fieldnames(raw);
    ppg = raw.(rawField{1});  % Get actual signal data

    % -------------------------------
    % Step 1: Preprocessing
    % -------------------------------
    windowed = applyHanningWindow(ppg);
    filtered = applyFIRBandpass(windowed, fs);
    subsampled = filtered(1:D:end);
    normalized = zscore(subsampled);

    % -------------------------------
    % Step 2: Feature Extraction
    % -------------------------------
    timeFreqFeats = extractFeatures(normalized, fs/D);         % Time/frequency domain
    waveletFeats  = extractWaveletFeatures(normalized);        % Wavelet features

    % -------------------------------
    % Step 3: Load Label (Glucose)
    % -------------------------------
    labelFile = strrep(file, 'signal', 'label');
    labelData = load(fullfile(labelPath, labelFile));
    labelField = fieldnames(labelData);
    labelTable = labelData.(labelField{1});
    glucose = labelTable{1, 'Glucose'};  % Extract glucose level

    % -------------------------------
    % Step 4: Append All to One Row
    % -------------------------------
    trial_id = file;
    features(i,:) = [{trial_id}, glucose, timeFreqFeats, waveletFeats];

end

% === Convert Extracted Features to Table and Save ===

% Define headers (must match number of columns in `features`)
headers = {'Trial_ID', 'Glucose', ...
    'Mean', 'STD', 'RMS', 'Skewness', 'Kurtosis', ...
    'PeakToPeak', 'PeakFreq', 'SpectralEntropy', 'NumPeaks', ...
    'AvgPeakHeight', 'AvgPeakDistance', ...
    'ApproxEntropy', 'SampleEntropy', 'DFA', ...
    'WaveletEnergy', 'WaveletEntropy'};

% Display dimensions for confirmation
disp("Number of columns in feature array:");
disp(size(features, 2));

disp("Number of headers:");
disp(length(headers));

% Confirm match
assert(length(headers) == size(features, 2), ...
    'Header count does not match feature columns');

% Convert to table
featureTable = cell2table(features, 'VariableNames', headers);

% Optional: Save as CSV and MAT
writetable(featureTable, fullfile('ML', 'ExtractedFeatures.csv'));
save(fullfile('ML', 'ExtractedFeaturesTable.mat'), 'featureTable');


   
    visualizeFeatures(featureTable, 'ML/PPG_FeatureSet.csv');
    disp(" Full pipeline executed and features extracted.");
end

%% ------------------------------------------
function zw = applyHanningWindow(signal)
    N = length(signal);
    n = 0:N-1;
    wn = 0.5 - 0.5 * cos(2 * pi * n / (N - 1));
    zw = signal(:) .* wn(:);
end

%% ------------------------------------------
function filtered = applyFIRBandpass(signal, fs)
    fc_low = 0.5; fc_high = 20;
    Q = 101; % Filter order
    h = firpm(Q-1, [0 fc_low-0.1 fc_low fc_high fc_high+10 fs/2]/(fs/2), [0 0 1 1 0 0]);
    filtered = filter(h, 1, signal);
end

%% ------------------------------------------
function x_norm = zscore(x)
    mu = mean(x);
    sigma = std(x);
    x_norm = (x - mu) / sigma;
end

%% ------------------------------------------
function feat = extractFeatures(signal, fs)
    % Time-domain
    mean_val = mean(signal);
    std_val = std(signal);
    rms_val = rms(signal);
    skew_val = skewness(signal);
    kurt_val = kurtosis(signal);
    peak2peak = max(signal) - min(signal);

    % Frequency-domain
    L = length(signal);
    Y = fft(signal);
    P2 = abs(Y/L); P1 = P2(1:floor(L/2)+1); P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(L/2))/L;
    [~, idx] = max(P1);
    peak_freq = f(idx);

    % Spectral Entropy
    psd = P1.^2; psd = psd / sum(psd);
    spectral_entropy = -sum(psd .* log2(psd + eps));

    % Morphological
    [pks, locs] = findpeaks(signal);
    num_peaks = length(pks);
    avg_pk_ht = mean(pks);
    avg_pk_dist = mean(diff(locs)) / fs;

    % Nonlinear Features
    apen = approximateEntropy(signal, 2, 0.2 * std(signal));
    sampen = sampleEntropy(signal, 2, 0.2 * std(signal));
    dfa_val = dfa(signal);

    wave_feats = extractWaveletFeatures(signal);  % New wavelet features

    % Final feature vector
    feat = {mean_val, std_val, rms_val, skew_val, kurt_val, peak2peak, ...
        peak_freq, spectral_entropy, num_peaks, avg_pk_ht, avg_pk_dist, ...
        apen, sampen, dfa_val,wave_feats};
end

%% ------------------------------------------
function ApEn = approximateEntropy(U, m, r)
    N = length(U);
    x = zeros(N - m + 1, m);
    for i = 1:(N - m + 1)
        x(i,:) = U(i:i + m - 1);
    end
    C = zeros(N - m + 1, 1);
    for i = 1:(N - m + 1)
        dist = max(abs(x - x(i,:)), [], 2);
        C(i) = sum(dist <= r) / (N - m + 1);
    end
    phi_m = sum(log(C + eps)) / (N - m + 1);
    % m+1
    m = m + 1;
    x = zeros(N - m + 1, m);
    for i = 1:(N - m + 1)
        x(i,:) = U(i:i + m - 1);
    end
    C = zeros(N - m + 1, 1);
    for i = 1:(N - m + 1)
        dist = max(abs(x - x(i,:)), [], 2);
        C(i) = sum(dist <= r) / (N - m + 1);
    end
    phi_m1 = sum(log(C + eps)) / (N - m + 1);
    ApEn = phi_m - phi_m1;
end

%% ------------------------------------------
function SampEn = sampleEntropy(U, m, r)
    N = length(U);
    A = 0; B = 0;
    for i = 1:N - m
        for j = i+1:N - m
            if max(abs(U(i:i+m-1) - U(j:j+m-1))) < r
                B = B + 1;
                if abs(U(i+m) - U(j+m)) < r
                    A = A + 1;
                end
            end
        end
    end
    SampEn = -log(A / (B + eps) + eps);
end

%% ------------------------------------------
function alpha = dfa(x)
%DFA Detrended Fluctuation Analysis for 1D time-series signal
%
%   alpha = dfa(x) returns the DFA exponent (scaling factor)
%   used to analyze long-range correlations in a signal.
%
%   INPUT:
%       x  - 1D signal vector (e.g., PPG or ECG)
%
%   OUTPUT:
%       alpha - DFA exponent (slope of log-log fluctuation vs window size)

    % Step 1: Integrate the signal
    x = x - mean(x);        % Remove mean
    y = cumsum(x);          % Integrated signal
    N = length(y);

    % Step 2: Define window scales (logarithmic spacing)
    scales = floor(logspace(log10(4), log10(floor(N/4)), 10));  % 10 scale levels
    F = zeros(length(scales), 1);  % To store fluctuation values

    % Step 3: Loop over window sizes
    for i = 1:length(scales)
        s = scales(i);                  % Current scale/window size
        nSegments = floor(N / s);       % Number of full windows
        fluct = zeros(nSegments, 1);    % Store local fluctuations

        for j = 1:nSegments
            idx = (j-1)*s + 1 : j*s;
            if length(idx) ~= s
                continue;
            end
        
            segment = y(idx);     % First get the values
            segment = segment(:); % Then convert to column vector
     % Force to column vector
            t = (1:s)';                % Column vector
            p = polyfit(t, segment, 1);
            trend = polyval(p, t);
            err = segment - trend;
        
            fluct(j,1) = mean((err).^2);   % Now this is a scalar
        end

        % Step 4: Aggregate root mean square fluctuation
        F(i) = sqrt(mean(fluct));
    end

    % Step 5: Line fit in log-log scale → DFA exponent (slope)
    coeffs = polyfit(log10(scales), log10(F), 1);
    alpha = coeffs(1);  % The slope is the DFA scaling exponent
end




function waveletFeats = extractWaveletFeatures(signal)
    % Use Daubechies 4 wavelet (db4)
    [c,l] = wavedec(signal, 4, 'db4');

    % Extract detail coefficients d1 to d4 and approximation a4
    d1 = detcoef(c,l,1);
    d2 = detcoef(c,l,2);
    d3 = detcoef(c,l,3);
    d4 = detcoef(c,l,4);
    a4 = appcoef(c,l,'db4',4);

    bands = {d1, d2, d3, d4, a4};
    waveletFeats = [];

    for i = 1:length(bands)
        b = bands{i};
        f1 = skewness(b);
        f2 = sum(abs(diff(b)));                           % Total Variation
        f3 = -sum((b/sum(b+eps)).*log2(b/sum(b+eps)+eps));% Entropy
        f4 = std(b);
        f5 = mean(b.^2);                                  % Avg power
        f6 = mean(abs(b));                                % Mean Abs Value

        waveletFeats = [waveletFeats, f1, f2, f3, f4, f5, f6];
    end

    % Time-domain: Coefficient of variation, total variation
    covar = std(signal) / mean(signal + eps);
    totalvar = sum(abs(diff(signal)));

    waveletFeats = [waveletFeats, covar, totalvar];
end

%%
function visualizeFeatures(featureTable, savePath)
% VISUALIZEFEATURES - Visualizes and analyzes extracted PPG features
%
% Usage:
%   visualizeFeatures(featureTable, 'ML/PPG_FeatureSet.csv')
%
% Arguments:
%   featureTable - MATLAB table containing features with headers like:
%                  ['ID', 'Glucose', 'Mean', ..., 'DFA']
%   savePath     - Path to save CSV file (e.g., 'ML/PPG_FeatureSet.csv')

    fprintf(" Preview of Extracted Features (First 10 Rows):\n");
    disp(head(featureTable, 10));

    % Convert table to array for plots
    featureNames = featureTable.Properties.VariableNames;
    data = table2array(featureTable(:, 3:end)); % skip ID and Glucose
    glucose = featureTable.Glucose;

    % ─────────────────────────────────────────────────────────────
    % 1. Scatter Plot of Each Feature vs Glucose
    % ─────────────────────────────────────────────────────────────
    numFeatures = size(data, 2);
    figure('Name', 'Features vs Glucose');
    tiledlayout(ceil(numFeatures/3), 3, 'Padding', 'compact');
    for i = 1:numFeatures
        nexttile;
        scatter(glucose, data(:, i), 20, 'filled');
        xlabel('Glucose'); ylabel(featureNames{i+2});
        title(strrep(featureNames{i+2}, '_', '\_'));
        grid on;
    end

    % ─────────────────────────────────────────────────────────────
    %  2. Correlation Matrix
    % ─────────────────────────────────────────────────────────────
    figure('Name', 'Correlation Matrix of Features');
    corrMat = corr(data);
    imagesc(corrMat);
    colorbar;
    axis square;
    xticks(1:numFeatures); yticks(1:numFeatures);
    xticklabels(featureNames(3:end)); yticklabels(featureNames(3:end));
    xtickangle(45);
    title('Correlation Heatmap of Extracted Features');

    % ─────────────────────────────────────────────────────────────
    %  3. PCA Visualization
    % ─────────────────────────────────────────────────────────────
    [coeff, score, ~, ~, explained] = pca(data);
    figure('Name', 'PCA of PPG Features');
    scatter(score(:,1), score(:,2), 40, glucose, 'filled');
    xlabel(['PC 1 (' num2str(round(explained(1),1)) '%)']);
    ylabel(['PC 2 (' num2str(round(explained(2),1)) '%)']);
    colorbar;
    title('PCA of Extracted PPG Features Colored by Glucose');

    % ─────────────────────────────────────────────────────────────
    %  4. Export to CSV
    % ─────────────────────────────────────────────────────────────
    if nargin > 1 && ~isempty(savePath)
        writetable(featureTable, savePath);
        fprintf(" Feature table saved to: %s\n", savePath);
    end

    fprintf("Visualization complete.\n");
end
