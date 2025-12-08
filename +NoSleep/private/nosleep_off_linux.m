function nosleep_off_linux(data)
% Linux backend: turn nosleep off for a specific PID struct.

    if nargin < 1 || isempty(data)
        return;
    end

    if ~isstruct(data) || ~isfield(data, "pid")
        error("NoSleep: 'data' must be a struct with field 'pid' returned by nosleep_on_linux().");
    end

    pid = data.pid;

    if isempty(pid) || ~isnumeric(pid) || isnan(pid) || pid <= 0
        return;
    end

    terminate_process_linux(pid, 800);
end
