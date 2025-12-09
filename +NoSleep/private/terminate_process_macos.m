function terminate_process_macos(pid, grace_ms)
% Terminate a process by PID with a short grace period.
% First sends SIGTERM, then (after a delay) SIGKILL.

    if nargin < 2
        grace_ms = 500;
    end

    if isempty(pid) || ~isnumeric(pid) || isnan(pid) || pid <= 0
        return;
    end

    % Graceful SIGTERM
    try
        system(sprintf('kill -TERM %d >/dev/null 2>&1', pid));
    catch
        % ignore
    end

    % Wait for a short grace period
    steps = max(1, floor(grace_ms / 50));
    for i = 1:steps
        pause(0.05);
    end

    % If still alive, send SIGKILL
    try
        system(sprintf('kill -KILL %d >/dev/null 2>&1', pid));
    catch
        % ignore
    end
end
