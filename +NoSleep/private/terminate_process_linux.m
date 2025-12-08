function terminate_process_linux(pid, grace_ms)
% Terminate a process by PID with a short grace period.
% First sends SIGTERM, then (optionally) SIGKILL.

    if nargin < 2
        grace_ms = 500;
    end

    if isempty(pid) || ~isnumeric(pid) || isnan(pid) || pid <= 0
        return;
    end

    % Try graceful SIGTERM
    try
        system(sprintf('kill -TERM %d >/dev/null 2>&1', pid));
    catch
        % ignore errors
    end

    % Wait for a short grace period
    steps = max(1, floor(grace_ms / 50));
    for i = 1:steps %#ok<NASGU>
        pause(0.05);
    end

    % If still alive, send SIGKILL (best effort)
    try
        system(sprintf('kill -KILL %d >/dev/null 2>&1', pid));
    catch
        % ignore errors
    end
end
