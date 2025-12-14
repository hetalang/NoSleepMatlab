function data = nosleep_on_linux(keep_display)
% Linux backend: start systemd-inhibit to block sleep.
% Returns struct with PID on success, or [] on failure.

    if nargin < 1
        keep_display = false;
    end

    keep_display = logical(keep_display);

    % Check if systemd-inhibit is available in PATH
    if ~have_systemd_inhibit()
        warning("NoSleep: 'systemd-inhibit' Linux backend is not available.");
        data = [];
        return;
    end

    if keep_display
        what = 'sleep:idle';
    else
        what = 'sleep';
    end

    % Construct command to start systemd-inhibit
    baseCmd  = sprintf('systemd-inhibit --what=%s --who=NoSleepMATLAB --why=Long_computation --mode=block sleep infinity', what);
    shellCmd = sprintf('%s >/dev/null 2>&1 & echo $!', baseCmd); % suppress output and run in background, capture output
    %fullCmd = sprintf('sh -c "%s"', shellCmd); % Run via /bin/sh and capture PID

    [~, cmdout] = system(shellCmd);

    % cmdout should contain the PID of the background process when successful
    if isempty(strtrim(cmdout))
        warning("NoSleep: no PID returned from 'systemd-inhibit' command.");
        data = [];
        return;
    end

    % PID should be the last token in the output; handle shells that prefix job info.
    % in R it looks like: pid_str <- utils::tail(out[nzchar(out)], 1L)
    pid_match = regexp(strtrim(cmdout), '(\d+)\s*$', 'tokens', 'once');
    if isempty(pid_match)
        error("NoSleep: could not read PID from systemd-inhibit output.");
    end

    pid_val = str2double(pid_match{1});

    if isnan(pid_val) || pid_val <= 0
        error("NoSleep: invalid PID parsed for 'systemd-inhibit' process.");
    end

    data = struct("pid", pid_val);
end
