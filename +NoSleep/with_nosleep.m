function varargout = with_nosleep(func, keep_display)
% Execute a function while nosleep is active.
%
% Usage:
%   result = with_nosleep(@() myLongJob());
%   result = with_nosleep(@() myLongJob(), true);

    if ~isa(func, 'function_handle')
        error('NoSleep:InvalidArgument', ...
              'First argument must be a function handle.');
    end

    if nargin < 2
        keep_display = false;
    end

    handle = NoSleep.nosleep_on(keep_display);

    num_outputs = nargout;
    varargout   = cell(1, num_outputs);

    % If backend failed and returned empty, just run normally
    if isempty(handle)
        if num_outputs == 0
            func();
        else
            [varargout{:}] = func();
        end
        return
    end

    cleaner = onCleanup(@() safe_nosleep_off(handle)); %#ok<NASGU>

    % Execute user code
    if num_outputs == 0
        func();
    else
        [varargout{:}] = func();
    end
end

function safe_nosleep_off(handle)
% Helper that turns off nosleep and ignores errors.

    try
        NoSleep.nosleep_off(handle);
    catch
        % ignore errors during cleanup
    end
end
