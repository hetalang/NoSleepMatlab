function out = nosleep_state(action, handle)
% Manage global list of active nosleep handles for the current MATLAB session.
%
% action:
%   'register'   - add handle
%   'unregister' - remove handle
%   'get_all'    - return all handles
%   'clear'      - clear all handles

    persistent handles

    if isempty(handles)
        handles = {};
    end

    switch action
        case 'register'
            handles{end+1} = handle;
            out = handle;

        case 'unregister'
            if nargin < 2
                return;
            end
            idxToKeep = true(size(handles));
            for i = 1:numel(handles)
                if isequal(handles{i}, handle)
                    idxToKeep(i) = false;
                end
            end
            handles = handles(idxToKeep);
            out = [];

        case 'get_all'
            out = handles;

        case 'clear'
            handles = {};
            out = {};

        otherwise
            error('NoSleep:InvalidAction', ...
                  'Unknown action "%s" in nosleep_state.', action);
    end
end
