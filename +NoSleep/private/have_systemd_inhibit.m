function tf = have_systemd_inhibit()
% Check if systemd-inhibit is available for use.

    if ~isunix || ismac
        tf = false;
        return;
    end

    % Check if systemd-inhibit is in PATH
    [status, cmdout] = system("which systemd-inhibit");
    if (status ~= 0) || isempty(strtrim(cmdout))
        tf = false;
        return;
    end

    % test access
    % Try to run to check access
    baseCmd = "systemd-inhibit --what=sleep --who=NoSleepMATLAB --why=Test --mode=block sleep 0";
    [testStatus, ~] = system(baseCmd);
    if testStatus ~= 0
        tf = false;
        return;
    end

    tf = true;
    return;
end
