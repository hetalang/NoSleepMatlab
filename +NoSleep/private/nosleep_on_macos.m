function data = nosleep_on_macos(keep_display)
% macOS backend: start 'caffeinate' to block system sleep.
% keep_display = true -> use '-d' to prevent display sleep as well.
% Returns struct with PID on success, or [] on failure.

    if nargin < 1
        keep_display = false;
    end

    keep_display = logical(keep_display);

    if ~have_caffeinate()
        warning("NoSleep: 'caffeinate' macOS backend is not available.");
        data = [];
        return;
    end

    % Base command
    % caffeinate [-d] -i -t 7200
    flag_d = "";
    if keep_display
        flag_d = "-d ";
    end
    % -i Idle system sleep
    % -d Idle display sleep
    % -m Disk sleep
    % -s System sleep when connected to AC power
    % -u User is active for 5 minutes
    % -t Timeout in seconds

    baseCmd = sprintf("caffeinate %s -s", flag_d);
    shellCmd = sprintf('%s >/dev/null 2>&1 & echo $!', baseCmd);
    %fullCmd  = sprintf('sh -c "%s"', shellCmd);

    [~, cmdout] = system(shellCmd);

    if isempty(strtrim(cmdout))
        warning("NoSleep: no PID returned from 'caffeinate' command.");
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
