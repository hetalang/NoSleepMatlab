function tf = have_systemd_inhibit()
% Check if systemd-inhibit is available in PATH on Linux.

    if ~isunix || ismac
        tf = false;
        return;
    end

    [status, cmdout] = system('which systemd-inhibit');
    tf = (status == 0) && ~isempty(strtrim(cmdout));
end
