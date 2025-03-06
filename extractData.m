% Set directory path for RawData
raw_data_path = 'PPG_Dataset/RawData';  % Change this to your actual path

% List all .mat files in the folder
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
        file_path = fullfile(raw_data_path, subject_files(j).name);
        data = load(file_path);

        % Extract variable name dynamically
        var_name = fieldnames(data);
        ppg_signal = data.(var_name{1}); % Extract PPG signal
        
        % Extract the trial number (000Y) for legend
        trial_number = extractAfter(subject_files(j).name, "_000");
        trial_number = erase(trial_number, ".mat"); % Remove file extension
        
        % Plot with a label for each trial
        plot(ppg_signal, 'DisplayName', ['Trial ', trial_number]);
    end
    
    % Add legend to distinguish different trials (000Y)
    legend show;
    hold off;
end


