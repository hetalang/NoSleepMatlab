function data = nosleep_on_linux(keep_display)
% Linux backend: start systemd-inhibit to block sleep.
% Returns struct with PID on success, or [] on failure.

    if nargin < 1
        keep_display = false;
    end

    keep_display = logical(keep_display);

    if ~have_systemd_inhibit()
        warning("NoSleep: 'systemd-inhibit' not found in PATH; Linux backend is not available.");
        data = [];
        return;
    end

    if keep_display
        what = 'sleep:idle';
    else
        what = 'sleep';
    end

    % Base command similar to R/Julia versions:
    % systemd-inhibit --what=... --who=NoSleepMATLAB --why=Long_computation --mode=block sleep infinity
    baseCmd  = sprintf('systemd-inhibit --what=%s --who=NoSleepMATLAB --why=Long_computation --mode=block sleep infinity', what);
    shellCmd = sprintf('%s >/dev/null 2>&1 & echo $!', baseCmd);

    % Run via /bin/sh and capture PID
    fullCmd = sprintf('sh -c "%s"', shellCmd);
    [status, cmdout] = system(fullCmd);

    if status ~= 0 || isempty(cmdout)
        warning("NoSleep: failed to start 'systemd-inhibit' via shell.");
        data = [];
        return;
    end

    % PID should be the last non-empty line
    lines = strsplit(strtrim(cmdout), {'\r', '\n'});
    lines = lines(~cellfun(@isempty, lines));
    if isempty(lines)
        error("NoSleep: could not read PID from systemd-inhibit output.");
    end

    pid_str = lines{end};
    pid_val = str2double(strtrim(pid_str));

    if isnan(pid_val) || pid_val <= 0
        error("NoSleep: invalid PID parsed for 'systemd-inhibit' process.");
    end

    data = struct("pid", pid_val);
end
