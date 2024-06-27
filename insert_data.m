% Assuming 'ans.run_2_json' and 'theta_events' are already loaded into workspace

% Extract timestamps from ans.run_2_json and theta_events
timestamps_ans = ans.run_2_json(:, 1);
timestamps_theta = theta_events(:, 1);

% Initialize a new column for theta_events data in ans.run_2_json
% Set default values to NaN or another placeholder to indicate unmatched entries
ans.run_2_json(:, 4) = NaN;

% Loop through timestamps in ans.run_2_json to find matches in theta_events
for i = 1:length(timestamps_ans)
    % Find index of the matching timestamp in theta_events
    idx = find(timestamps_theta == timestamps_ans(i));
    
    % If a match is found, copy the corresponding value from theta_events
    if ~isempty(idx)
        ans.run_2_json(i, 4) = theta_events(idx, 2);
    end
end

% Now ans.run_2_json contains the new column with matched values from theta_events
