function varargout = with_nosleep(func, keep_display)
%WITH_NOSLEEP Execute a function while preventing system sleep.
%
% Syntax:
%   NoSleep.with_nosleep(func)
%   NoSleep.with_nosleep(func, keep_display)
%
% Input:
%   func (function_handle)
%     Function handle to execute while nosleep is active.
%
%   keep_display (logical scalar, optional)
%     true  - also prevent display sleep
%     false - prevent only system sleep (default)
%
% Output:
%   varargout
%     Outputs returned by the executed function. If func produces no
%     outputs, WITH_NOSLEEP also returns none.
%
% Description:
%   WITH_NOSLEEP enables nosleep, executes the provided function, and
%   guarantees that nosleep is disabled afterward, even if the function
%   throws an error.
%
%   If no supported backend is available on the current platform,
%   WITH_NOSLEEP executes the function normally without error.
%
% Example:
%   NoSleep.with_nosleep(@() pause(10))
%
%   result = NoSleep.with_nosleep(@() sum(1:10), true)
%
% See also: NoSleep.nosleep_on, NoSleep.nosleep_off

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
