function nosleep_off_windows(data)
% Clears a previously created request.
%
% data: struct with field "id"

if isempty(data) || ~isstruct(data) || ~isfield(data, "id")
    return;
end

nosleep_win('clear', data.id);
end
