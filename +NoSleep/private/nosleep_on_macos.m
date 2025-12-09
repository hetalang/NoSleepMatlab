function data = nosleep_on_macos(keep_display)
% macOS backend: start 'caffeinate' to block system sleep.
% keep_display = true -> use '-d' to prevent display sleep as well.
% Returns struct with PID on success, or [] on failure.

    if nargin < 1
        keep_display = false;
    end

    keep_display = logical(keep_display);

    if ~have_caffeinate()
        warning("NoSleep: 'caffeinate' not found in PATH; macOS backend is not available.");
        data = [];
        return;
    end

    % Finite timeout (2 hours) to avoid infinite lock if teardown fails.
    timeout_sec = 7200;

    % Base command
    % caffeinate [-d] -i -t 7200
    flag_d = "";
    if keep_display
        flag_d = "-d ";
    end

    baseCmd = sprintf("caffeinate %s-i -t %d", flag_d, timeout_sec);

    % Start caffeinate in background and echo its PID
    shellCmd = sprintf('%s >/dev/null 2>&1 & echo $!', baseCmd);
    fullCmd  = sprintf('sh -c "%s"', shellCmd);

    [status, cmdout] = system(fullCmd);

    if status ~= 0 || isempty(cmdout)
        warning("NoSleep: failed to start 'caffeinate' via shell.");
        data = [];
        return;
    end

    % Extract PID from last non-empty line
    lines = strsplit(strtrim(cmdout), {'\r', '\n'});
    lines = lines(~cellfun(@isempty, lines));

    if isempty(lines)
        error("NoSleep: could not read PID from caffeinate output.");
    end

    pid_val = str2double(strtrim(lines{end}));

    if isnan(pid_val) || pid_val <= 0
        error("NoSleep: invalid PID parsed for 'caffeinate' process.");
    end

    data = struct("pid", pid_val);
end
