function nosleep_off_macos(data)
% macOS backend: stop the caffeinate process for a specific PID.

    if nargin < 1 || isempty(data)
        return;
    end

    if ~isstruct(data) || ~isfield(data, "pid")
        error("NoSleep: 'data' must be a struct with field 'pid' returned by nosleep_on_macos().");
    end

    pid = data.pid;

    if isempty(pid) || ~isnumeric(pid) || isnan(pid) || pid <= 0
        return;
    end

    terminate_process_macos(pid, 800);
end
