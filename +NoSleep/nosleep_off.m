function nosleep_off(handle)
% Turn off a specific nosleep request or all active ones.
%
% Usage:
%   nosleep_off(handle);    % turn off specific handle
%   nosleep_off();          % turn off all active handles
%   nosleep_off([]);        % no-op

    % Case 1: no argument -> turn off all
    if nargin == 0
        nosleep_off_all();
        return;
    end

    % Case 2: explicit empty -> no-op
    if isempty(handle)
        return;
    end

    % Basic sanity check
    if ~isstruct(handle) || ~isfield(handle, 'backend') || ~isfield(handle, 'data')
        error('NoSleep:InvalidHandle', ...
              'Handle must be a struct with fields "backend" and "data".');
    end

    backend = handle.backend;
    data    = handle.data;

    % Detect current OS
    if ispc && strcmp(backend, 'windows')
        nosleep_off_windows(data);
    elseif ismac && strcmp(backend, 'macos')
        nosleep_off_macos(data);
    elseif isunix && strcmp(backend, 'linux')
        nosleep_off_linux(data);
    else
        error('NoSleep:HandleMismatch', ...
              'Handle backend "%s" is not compatible with current OS.', backend);
    end

    % Unregister handle from global state
    nosleep_state('unregister', handle);
end

function nosleep_off_all()
% Turn off all active nosleep requests for the current session.

    handles = nosleep_state('get_all');

    for i = 1:numel(handles)
        h = handles{i};
        if isstruct(h) && isfield(h, 'backend') && isfield(h, 'data')
            % Best-effort: ignore errors during bulk shutdown
            try
                NoSleep.nosleep_off(h);
            catch
                % swallow errors to ensure all handles are attempted
            end
        end
    end

    nosleep_state('clear');
end
