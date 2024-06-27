% Define the regex pattern for the time format 'HH:MM:SS.ssssss'
timePattern = '\d{2}:\d{2}:\d{2}\.\d+';

% Initialize an array to store the indices of rows that match the pattern
matchedIndices = false(length(EEG.event), 1);

% Loop through each row in EEG.event and check if it matches the pattern
for i = 1:length(EEG.event)
    if ischar(EEG.event(i).type)
        % Check if the type field matches the regex pattern
        if ~isempty(regexp(EEG.event(i).type, timePattern, 'once'))
            matchedIndices(i) = true;
        end
    end
end

% Filter the EEG.event structure to keep only the matching rows
filteredEvents = EEG.event(matchedIndices);

% Update the EEG.event structure
EEG.event = filteredEvents;