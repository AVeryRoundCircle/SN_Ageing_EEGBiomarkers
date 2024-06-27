% retains int events only
% deletes int event greater than 5
% deletes first 5 rows 


integerPattern = '^\d+$';

% Initialize an array to store the indices of events that match the integer and value conditions
validIndices = false(length(EEG.event), 1);

% Loop through each event in EEG.event and apply all filters
for i = 1:length(EEG.event)
    if ischar(EEG.event(i).type) || isnumeric(EEG.event(i).type)
        % Convert the type to string for uniform processing
        typeStr = num2str(EEG.event(i).type);

        % Check if the type field matches the regex pattern for integers
        if ~isempty(regexp(typeStr, integerPattern, 'once'))
            % Convert string to number if possible
            numericType = str2double(typeStr);

            % Check if numeric type is not greater than 5
            if ~isnan(numericType) && numericType <= 5
                validIndices(i) = true;
            end
        end
    end
end

% Apply index filter to keep only valid events
EEG.event = EEG.event(validIndices);

% Additional check to remove the first five remaining events if there are enough events
if length(EEG.event) > 5
    EEG.event = EEG.event(6:end);
else
    EEG.event = [];
end