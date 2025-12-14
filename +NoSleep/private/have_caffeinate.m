function tf = have_caffeinate()
% Check if the 'caffeinate' utility is available in PATH (macOS only).

    if ~ismac
        tf = false;
        return;
    end

    [status, cmdout] = system("which caffeinate");
    if (status ~= 0) || isempty(strtrim(cmdout))
        tf = false;
        return;
    end

    % test access not sure it required
    % additiona check by running a simple caffeinate command
    %baseCmd = "caffeinate -s -t 1";
    %[testStatus, ~] = system(baseCmd);
    %if testStatus ~= 0
    %    tf = false;
    %    return;
    %end
    
    tf = true;
    return;
end
