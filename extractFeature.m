% Define directory paths
cleaned_data_path = 'PPG_Dataset/CleanedData';  % Path to cleaned PPG signals
labels_path = 'PPG_Dataset/Labels';             % Path to glucose levels
ml_data_path = 'ML';                % Path for storing extracted features

% Create ML folder if it does not exist
if ~exist(ml_data_path, 'dir')
    mkdir(ml_data_path);
end

% List all .mat files in the CleanedData folder
clean_files= dir(fullfile(cleaned_data_path, '*.mat'));
num_files = length(clean_files);

% Initialize dataset storage
feature_table = [];

% Iterate through each cleaned PPG signal file
for i = 1:num_files
    % Extract file name and subject-trial ID
    clean_file_name = clean_files(i).name;
    subject_trial_id = erase(clean_file_name, ".mat"); % Remove file extension
    
    % Convert subject_trial_id to cell array (Fixes the table error)
    subject_trial_id_cell = {subject_trial_id}; % Store as cell array

    % Load cleaned PPG signal
    clean_file_path = fullfile(cleaned_data_path, clean_file_name);
    clean_data = load(clean_file_path);
    var_name = fieldnames(clean_data);
    ppg_signal = clean_data.(var_name{1}); % Extract cleaned PPG signal
    
    % Load corresponding label file (glucose level)
    label_file_name = strrep(clean_file_name, "signal", "label"); % Convert signal filename to label filename
    label_file_path = fullfile(labels_path, label_file_name);
    
    % Check if the corresponding label file exists
    if exist(label_file_path, 'file')
        label_data = load(label_file_path);
        label_var = fieldnames(label_data);
        glucose_level = label_data.(label_var{1}){1, 'Glucose'}; % Extract glucose level
    else
        glucose_level = NaN; % Assign NaN if no label is found
    end

    % **Time-Domain Features**
    mean_value = mean(ppg_signal);
    std_dev = std(ppg_signal);
    rms_value = rms(ppg_signal);
    skewness_value = skewness(ppg_signal);
    kurtosis_value = kurtosis(ppg_signal);
    peak_to_peak = max(ppg_signal) - min(ppg_signal);
    
    % **Frequency-Domain Features**
    fs = 1000; % Sampling frequency (assumed)
    N = length(ppg_signal);
    Y = fft(ppg_signal);
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(N/2))/N; % Frequency vector
    peak_freq = f(find(P1 == max(P1), 1)); % Find peak frequency
    
    % **Spectral Entropy**
    psd = P1.^2;
    psd_norm = psd / sum(psd);
    spectral_entropy = -sum(psd_norm .* log2(psd_norm + eps));

    % **Morphological Features**
    [pks, locs] = findpeaks(ppg_signal); % Find peaks
    num_peaks = length(pks); % Number of peaks
    avg_peak_height = mean(pks); % Mean peak height
    avg_peak_distance = mean(diff(locs)) / fs; % Average peak-to-peak interval (in seconds)

    % **Compile Feature Set (Fixed Table Issue)**
    features = cell2table([subject_trial_id_cell, num2cell(glucose_level), num2cell(mean_value), ...
        num2cell(std_dev), num2cell(rms_value), num2cell(skewness_value), num2cell(kurtosis_value), ...
        num2cell(peak_to_peak), num2cell(peak_freq), num2cell(spectral_entropy), ...
        num2cell(num_peaks), num2cell(avg_peak_height), num2cell(avg_peak_distance)], ...
        'VariableNames', {'Trial_ID', 'Glucose_Level', 'Mean', 'STD', 'RMS', 'Skewness', ...
        'Kurtosis', 'Peak_to_Peak', 'Peak_Freq', 'Spectral_Entropy', 'Num_Peaks', ...
        'Avg_Peak_Height', 'Avg_Peak_Distance'});

    % Append to dataset
    feature_table = [feature_table; features];
end

% Save dataset as a MATLAB table
save(fullfile(ml_data_path, 'PPG_Features.mat'), 'feature_table');

% Save dataset as a CSV file for machine learning
writetable(feature_table, fullfile(ml_data_path, 'PPG_Features.csv'));

disp("Feature extraction complete! Data saved in 'ML' folder.");
