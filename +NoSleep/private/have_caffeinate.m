function tf = have_caffeinate()
% Check if the 'caffeinate' utility is available in PATH (macOS only).

    if ~ismac
        tf = false;
        return;
    end

    [status, cmdout] = system('which caffeinate');
    tf = (status == 0) && ~isempty(strtrim(cmdout));
end
