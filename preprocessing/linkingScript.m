% Set directory paths
raw_data_path = './PPG_Dataset/RawData';  % Change to actual path
labels_path = '../PPG_Dataset/Labels';     % Change to actual path

% List all .mat files in the RawData folder
raw_files = dir(fullfile(raw_data_path, '*.mat'));
num_files = length(raw_files);

% Initialize dataset storage
all_data = struct(); % Store structured data

% Iterate through each signal file
for i = 1:num_files
    % Get file name and subject ID
    raw_file_name = raw_files(i).name;
    subject_trial_id = erase(raw_file_name, ".mat"); % Remove file extension
    
    % Load PPG signal
    file_path = fullfile(raw_data_path, raw_file_name);
    data = load(file_path);
    
    % Extract variable name dynamically
    var_name = fieldnames(data);
    ppg_signal = data.(var_name{1}); % Extract PPG signal
    
    % Load corresponding label file (glucose level)
    label_file_name = strrep(raw_file_name, "signal", "label"); % Replace "signal" with "label"
    label_file_path = fullfile(labels_path, label_file_name);
    
    % Check if the corresponding label file exists
    if exist(label_file_path, 'file')
        label_data = load(label_file_path);
        label_var = fieldnames(label_data);
        
        % Extract glucose level (4th column)
        glucose_level = label_data.(label_var{1}){1, 'Glucose'}; % Extract glucose correctly
        
        % Store in struct
        all_data(i).ID = subject_trial_id;
        all_data(i).PPG_Signal = ppg_signal;
        all_data(i).Glucose_Level = glucose_level;
    else
        disp(['Warning: No label found for ', raw_file_name]);
    end
end

% Save dataset to .mat file
save('PPG_Glucose_Dataset.mat', 'all_data');

% Convert to table format for easier export
dataset_table = struct2table(all_data);

% Save to CSV (excluding PPG signal for readability)
dataset_csv = dataset_table(:, {'ID', 'Glucose_Level'}); % Exclude full PPG signals in CSV
writetable(dataset_csv, 'PPG_Glucose_Dataset.csv');

disp("PPG dataset successfully linked with glucose levels and saved!");
