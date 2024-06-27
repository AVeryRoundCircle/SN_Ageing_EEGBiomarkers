% Number of events in the EEG structure
numEvents = length(EEG.event);

% Initialize the trial number
trialNum = 1;

% Loop through each event in sets of three
for i = 1:3:numEvents
    % Loop through each of the three events in the set
    for j = i:min(i+2, numEvents) % Ensure we do not go out of bounds
        % Check if type is numeric and convert to string, if necessary
        if isnumeric(EEG.event(j).type)
            currentType = num2str(EEG.event(j).type);
        else
            currentType = EEG.event(j).type;
        end

        % Append "_trialx" to the current event type, where x is the trial number
        EEG.event(j).type = [currentType '_trial' num2str(trialNum)];
    end
    
    % Increment the trial number after every three events
    trialNum = trialNum + 1;
end