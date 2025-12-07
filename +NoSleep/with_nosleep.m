function result = with_nosleep(func, varargin)
% Execute a function while nosleep is active.
%
% Usage:
%   result = with_nosleep(@() myLongJob());
%   result = with_nosleep(@() myLongJob(), 'keep_display', true);

    if ~isa(func, 'function_handle')
        error('NoSleep:InvalidArgument', ...
              'First argument must be a function handle.');
    end

    handle = nosleep_on(varargin{:});

    % If backend failed and returned empty, just run normally
    if isempty(handle)
        result = func();
        return;
    end

    cleaner = onCleanup(@() safe_nosleep_off(handle));

    % Execute user code
    result = func();

    % onCleanup will take care of turning off nosleep
end

function safe_nosleep_off(handle)
% Helper that turns off nosleep and ignores errors.

    try
        nosleep_off(handle);
    catch
        % ignore errors during cleanup
    end
end
