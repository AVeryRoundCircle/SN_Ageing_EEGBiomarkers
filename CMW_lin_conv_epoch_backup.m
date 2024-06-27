% Add EEGLAB to the MATLAB path
addpath('/Users/stevenlieu/EEGLAB/eeglab2023.1');
% Start EEGLAB without GUI
eeglab nogui;
% Define the file path for EEG data set
setFilePath = '/Users/stevenlieu/EEGLAB/eeglab2023.1/data/LSL_validation/data_2006/';
% Load the EEG data set
EEG = pop_loadset('mark_test1.set', setFilePath);
% % Specify the channel to analyze
% chan2use = 'C21';
% 
% %Find the index of the specified channel
% chanIdx = find(strcmp({EEG.chanlocs.labels}, chan2use));
% 
% %Check if the channel was found
% if isempty(chanIdx)
%    error('Specified channel not found in EEG data.');
% end


% deletes events as they are duplicates and non-informative 
filter_events 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Epoching based on events and store duration in samples or ms %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assuming 'type', 'latency', and 'duration'!
numEvents = length(EEG.event);
epochs = cell(numEvents-1, 4); % cell array to store epoch data; 4 indicates that each cell 

for i = 1:numEvents-1
    % Get the start and end latencies of the epoch
    startLatency = round(EEG.event(i).latency);
    endLatency = round(EEG.event(i+1).latency);

    % Calculate duration in samples and time (ms)
    durationInSamples = endLatency - startLatency + 1; %+1 to ensure endpoints are included
    durationInSeconds = durationInSamples / EEG.srate;

    % Extract the epoch from the EEG data, focusing on the specified channel only
    %epochs{i, 1} = EEG.data(chanIdx, startLatency:endLatency); % Extract data for specified channel
    epochs{i, 2} = EEG.event(i).type;  % Store the event type
    epochs{i, 3} = durationInSamples;  % Store the duration in samples
    epochs{i, 4} = durationInSeconds;  % Store the duration in seconds
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Wavelet Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta_freq_range = [4, 8]; 
num_cycles = 3; 

frequencies = linspace(theta_freq_range(1), theta_freq_range(2), 20);
theta_power = cell(numEvents - 1, 1);  % Store theta power for each epoch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the wavelet parameters but adjusting for different epoch lengths convolution as well
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% for each epoch, we define their own time array, wavelets and fft length 
for i = 1:size(epochs, 1)
    epoch_data = epochs{i, 1};  % Extract the data for the current epoch
    epoch_length = epochs{i, 3};  % Get the duration of the current epoch in samples

    % time array for the current epoch
    time = linspace(-epoch_length / 2 / EEG.srate, epoch_length / 2 / EEG.srate, epoch_length);

    % precompute wavelets for time array 
    wavelet_data = cell(length(frequencies), 1);
    
    % Determine the FFT length for the current epoch 
    fft_length = 2^nextpow2(epoch_length + length(time) - 1); 
    
    for j = 1:length(frequencies)
        % Adjust standard deviation based on cycles and frequency
        s = num_cycles / (2 * pi * frequencies(j));
        wavelet = exp(2 * 1i * pi * frequencies(j) * time) .* exp(-time.^2 / (2 * s^2)); 
      
        % Store precomputed Fourier transform + zero padding
        wavelet_data{j} = fft(wavelet, fft_length);
    end

    % Compute FFT of the epoch data once
    epoch_fft = fft(epoch_data, fft_length); 
    conv_results = zeros(length(frequencies), epoch_length); % array to store

    % Convolve with wavelets
    for j = 1:length(frequencies)
        conv_result = ifft(epoch_fft .* wavelet_data{j}, 'symmetric');  
        
        % Adjust the start and end based on the length of the time array
        start_idx = (fft_length - epoch_length) / 2 + 1;
        end_idx = start_idx + epoch_length - 1;

        % Extract the relevant portion of the time-domain convolution result 
        if start_idx >= 1 && end_idx <= fft_length
            conv_results(j, :) = conv_result(start_idx:end_idx);
        else
            error('Index out of bounds');
        end
    end
    
    % Compute power for the epoch
    theta_power{i} = abs(conv_results).^2; % Calculate power for the whole epoch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% avg power over freq for each epoch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_epochs = length(theta_power);
averaged_theta_power = zeros(num_epochs, 1); % array to store the averaged theta power for each epoch

% Loop through each epoch to calculate the average theta power
for i = 1:num_epochs
    % Get the power data for the current epoch
    epoch_power = theta_power{i};  
    
    % Average the power across all frequencies within the theta band
    mean_power_in_theta = mean(epoch_power(:));  % Flatten with parentheses
    
    % Store the averaged power in the array
    averaged_theta_power(i) = mean_power_in_theta;  % Use parentheses for indexing
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Theta power transformation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

averaged_theta_power(averaged_theta_power <= 0) = eps; % Avoid log of zero or negative

log_averaged_theta_power = log(averaged_theta_power);

normalized_theta_power = log_averaged_theta_power - mean(log_averaged_theta_power);



% Display the normalized theta power that includes positive and negative values
disp('Normalized Theta Power (centered around zero):');
disp(normalized_theta_power);
