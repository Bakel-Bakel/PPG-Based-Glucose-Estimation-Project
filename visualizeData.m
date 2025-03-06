% Set directory paths
raw_data_path = 'PPG_Dataset/RawData';  % Change to actual path
labels_path = 'PPG_Dataset/Labels';     % Change to actual path

% List all .mat files in the RawData folder
raw_files = dir(fullfile(raw_data_path, '*.mat'));
num_files = length(raw_files);

% Extract unique subject IDs (XX from signal_XX_000Y.mat)
subject_ids = unique(extractBetween({raw_files.name}, "signal_", "_000"));

% Iterate through each unique subject ID
for i = 1:length(subject_ids)
    subject_id = subject_ids{i};
    
    % Filter files that belong to the current subject
    subject_files = raw_files(contains({raw_files.name}, ['signal_', subject_id, '_000']));
    
    % Create a new figure for this subject
    figure;
    hold on; % Enable multiple plots on the same figure
    title(['PPG Signals for Subject ', subject_id]);
    xlabel('Time');
    ylabel('Amplitude');
    grid on;

    % Iterate through all trials (000Y) for this subject
    for j = 1:length(subject_files)
        % Load the PPG signal file
        raw_file_name = subject_files(j).name;
        file_path = fullfile(raw_data_path, raw_file_name);
        data = load(file_path);

        % Extract variable name dynamically
        var_name = fieldnames(data);
        ppg_signal = data.(var_name{1}); % Extract PPG signal
        
        % Extract the corresponding label file (glucose level)
        label_file_name = strrep(raw_file_name, "signal", "label"); % Change signal to label
        label_file_path = fullfile(labels_path, label_file_name);
        label_data = load(label_file_path);

        % Extract glucose level correctly
        label_var = fieldnames(label_data);
        glucose_level = label_data.(label_var{1}){1, 'Glucose'}; % Extract glucose level
        
        % Extract the trial number (000Y) for legend
        trial_number = extractAfter(raw_file_name, "_000");
        trial_number = erase(trial_number, ".mat"); % Remove file extension
        
        % Plot signal and label it with glucose level
        plot(ppg_signal, 'DisplayName', ['Trial ', trial_number, ' - Glucose: ', num2str(glucose_level)]);
    end
    
    % Add legend to distinguish trials by glucose level
    legend show;
    hold off;
end
