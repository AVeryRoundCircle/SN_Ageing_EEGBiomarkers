

% Add EEGLAB to the MATLAB path
addpath('/Users/stevenlieu/EEGLAB/eeglab2023.1');

% Define the file path for EEG data set
setFilePath = '/Users/stevenlieu/EEGLAB/eeglab2023.1/data';
% Load the EEG data set

EEG = pop_loadxdf('/Users/stevenlieu/EEGLAB/eeglab2023.1/data/LSL_validation/trial2_duexdf/1hz.xdf' , 'streamtype', 'EEG', 'exclude_markerstreams', {});

% Define the channels to remove based on their labels
channels_to_remove = {'Trig1', 'EX7', 'EX8', 'AUX1', 'AUX2', 'AUX3', 'AUX4', 'AUX5', 'AUX6', 'AUX7', 'AUX8', 'AUX9', 'AUX10', 'AUX11', 'AUX12', 'AUX13', 'AUX14', 'AUX15', 'AUX16'};
channel_indices = find(ismember({EEG.chanlocs.labels}, channels_to_remove));

% Remove the unnecessary channels
EEG = pop_select(EEG, 'nochannel', channel_indices);

% Load the new channel locations file (XYZ format)
EEG = pop_chanedit(EEG, 'load', {'/Users/stevenlieu/Desktop/Whelan Lab/5. EEG/EEG layout/134locs.xyz', 'filetype', 'xyz'});

EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',100,'plotfreqz',1);

EEG = pop_saveset( EEG, 'filename','1hz.set','filepath','/Users/stevenlieu/EEGLAB/eeglab2023.1/data/LSL_validation/trial2_duexdf/');