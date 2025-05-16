function plotPPGComparison(subject_id, trial_number)
    % Function to plot raw vs. cleaned PPG signals for a specific subject and trial.
    % Inputs:
    %   subject_id: String or number representing subject ID (e.g., '01')
    %   trial_number: String or number representing trial number (e.g., '0001')
    
    % Define paths
    raw_data_path = '../PPG_Dataset/RawData';      % Path to raw data
    cleaned_data_path = '../PPG_Dataset/CleanedData'; % Path to cleaned signals

    % Construct file names
    file_name = sprintf('signal_%s_%s.mat', subject_id, trial_number);
    
    % Full paths
    raw_file_path = fullfile(raw_data_path, file_name);
    clean_file_path = fullfile(cleaned_data_path, file_name);
    
    % Check if files exist
    if ~exist(raw_file_path, 'file')
        error('Raw data file %s not found.', file_name);
    end
    if ~exist(clean_file_path, 'file')
        error('Cleaned data file %s not found.', file_name);
    end

    % Load raw PPG signal
    raw_data = load(raw_file_path);
    var_name = fieldnames(raw_data);
    ppg_signal = raw_data.(var_name{1}); % Extract raw PPG signal

    % Load cleaned PPG signal
    clean_data = load(clean_file_path);
    clean_signal = clean_data.clean_ppg; % Extract cleaned signal

    % Plot raw vs cleaned PPG signals
    figure;
    subplot(1,2,1);
    plot(ppg_signal, 'r');
    title(['Raw PPG Signal: ', file_name], 'Interpreter', 'none');
    xlabel('Time');
    ylabel('Amplitude');
    grid on;

    subplot(1,2,2);
    plot(clean_signal, 'b', 'LineWidth', 1.5);
    title(['Cleaned PPG Signal: ', file_name], 'Interpreter', 'none');
    xlabel('Time');
    ylabel('Amplitude');
    grid on;

    disp([' Comparison plot generated for Subject ', subject_id, ', Trial ', trial_number]);
end


function plotAllTrialsForSubject(subject_id)
    % Function to plot all PPG trials (000Y) for a given subject (XX) with glucose levels
    % Inputs:
    %   subject_id: String or number representing subject ID (e.g., '01')

    % Define paths
    raw_data_path = '../PPG_Dataset/RawData';       % Path to raw data
    cleaned_data_path = '../PPG_Dataset/CleanedData'; % Path to cleaned signals
    labels_path = '../PPG_Dataset/Labels';          % Path to label files

    % Get all available trials (000Y) for the given subject
    raw_files = dir(fullfile(raw_data_path, sprintf('signal_%s_*.mat', subject_id)));
    num_trials = length(raw_files);

    % Check if trials exist
    if num_trials == 0
        error('No trials found for Subject %s.', subject_id);
    end

    % Create figure for plotting
    figure;
    sgtitle(['PPG Signals for Subject ', subject_id]);

    % Loop through each trial and plot raw and cleaned data
    for i = 1:num_trials
        % Extract trial number (000Y)
        raw_file_name = raw_files(i).name;
        trial_number = extractBetween(raw_file_name, sprintf('signal_%s_', subject_id), '.mat');
        trial_number = trial_number{1}; % Convert from cell to string

        % Full paths for raw, cleaned, and label data
        raw_file_path = fullfile(raw_data_path, raw_file_name);
        clean_file_path = fullfile(cleaned_data_path, raw_file_name);
        label_file_path = fullfile(labels_path, strrep(raw_file_name, "signal", "label")); % Convert raw filename to label filename

        % Load raw PPG signal
        raw_data = load(raw_file_path);
        var_name = fieldnames(raw_data);
        ppg_signal = raw_data.(var_name{1}); % Extract raw PPG signal

        % Load cleaned PPG signal
        if exist(clean_file_path, 'file')
            clean_data = load(clean_file_path);
            clean_signal = clean_data.clean_ppg; % Extract cleaned signal
        else
            clean_signal = nan(size(ppg_signal)); % Placeholder if clean data is missing
        end

        % Load glucose level
        if exist(label_file_path, 'file')
            label_data = load(label_file_path);
            label_var = fieldnames(label_data);
            glucose_level = label_data.(label_var{1}){1, 'Glucose'}; % Extract glucose level
        else
            glucose_level = NaN; % Placeholder if label data is missing
        end

        % Plot raw PPG signal (left side)
        subplot(num_trials, 2, (i-1)*2 + 1);
        plot(ppg_signal, 'r');
        title(['Raw: Trial ', trial_number, ' - Glucose: ', num2str(glucose_level)]);
        xlabel('Time');
        ylabel('Amplitude');
        grid on;

        % Plot cleaned PPG signal (right side)
        subplot(num_trials, 2, (i-1)*2 + 2);
        plot(clean_signal, 'b', 'LineWidth', 1.5);
        title(['Cleaned: Trial ', trial_number, ' - Glucose: ', num2str(glucose_level)]);
        xlabel('Time');
        ylabel('Amplitude');
        grid on;
    end

    disp(['Comparison plots generated for Subject ', subject_id, ' with ', num2str(num_trials), ' trials and glucose levels.']);
end




% Set directory path for RawData
raw_data_path = '../PPG_Dataset/RawData';  % Change to actual path
filtered_data_path = '../PPG_Dataset/CleanedData'; % Folder for storing cleaned signals
if ~exist(filtered_data_path, 'dir')
    mkdir(filtered_data_path);
end

% List all .mat files in the RawData folder
raw_files = dir(fullfile(raw_data_path, '*.mat'));
num_files = length(raw_files);

% FIR Filter Design (Low-pass Filter)
fs = 435;  % Sampling frequency 
fc = 5;     % Cutoff frequency in Hz
N = 50;     % Filter order
fir_coeff = fir1(N, fc/(fs/2), 'low'); % Low-pass FIR filter design

% Iterate through each PPG signal file and clean it
for i = 1:num_files
    % Load raw PPG signal
    raw_file_name = raw_files(i).name;
    file_path = fullfile(raw_data_path, raw_file_name);
    data = load(file_path);

    % Extract variable name dynamically
    var_name = fieldnames(data);
    ppg_signal = data.(var_name{1}); % Extract PPG signal
    
    % Apply FIR filter (clean the signal)
    clean_ppg = filtfilt(fir_coeff, 1, ppg_signal);
    
    % Save the cleaned signal in a new file
    clean_file_path = fullfile(filtered_data_path, raw_file_name);
    save(clean_file_path, 'clean_ppg');
end


plotAllTrialsForSubject('01');
plotAllTrialsForSubject('12');

%plotPPGComparison('12', '0001');

disp("All PPG signals have been cleaned and saved in 'CleanedData' folder.");
