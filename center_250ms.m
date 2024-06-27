% Assuming EEG.epochs is a

% Extract the fourth column from the cell array
column4 = epochs(:, 4);

% Initialize the latency variable
latency = zeros(size(column4));

% Iterate through each value in the fourth column and subtract 0.250
for i = 1:length(column4)
    latency(i) = column4{i} - 0.250;
end

% Convert latency to a column vector
latency = latency(:);

