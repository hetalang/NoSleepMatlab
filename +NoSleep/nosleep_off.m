function nosleep_off(handle)
%NOSLEEP_OFF Release one or all active nosleep requests.
%
% Syntax:
%   NoSleep.nosleep_off(handle)
%   NoSleep.nosleep_off()
%   NoSleep.nosleep_off([])
%
% Input:
%   handle (struct, optional)
%     Handle previously returned by NoSleep.nosleep_on().
%
% Behavior:
%   - NoSleep.nosleep_off(handle) releases a specific nosleep request.
%   - NoSleep.nosleep_off() releases all active nosleep requests created
%     in the current MATLAB session.
%   - NoSleep.nosleep_off([]) is a no-op.
%
% Errors:
%   Throws an error if the handle is invalid or incompatible with the
%   current operating system.
%
% See also: NoSleep.nosleep_on, NoSleep.with_nosleep


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
