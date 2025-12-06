function handle = nosleep_on(varargin)
% Prevent the operating system from suspending while MATLAB work is running.
%
% Usage:
%   handle = nosleep_on();
%   handle = nosleep_on('keep_display', true);

    % Parse input arguments
    keepDisplay = false;
    if mod(numel(varargin), 2) ~= 0
        error('NoSleep:InvalidArguments', ...
              'Arguments must be specified as name-value pairs.');
    end

    for i = 1:2:numel(varargin)
        name  = lower(string(varargin{i}));
        value = varargin{i+1};
        switch name
            case "keep_display"
                keepDisplay = logical(value);
            otherwise
                error('NoSleep:InvalidOption', ...
                      'Unknown option "%s".', name);
        end
    end

    backend = '';
    data    = [];

    % OS detection and backend dispatch
    if ispc
        backend = 'windows';
        % TODO: implement backend-specific function in +NoSleep/private
        data = nosleep_on_windows(keepDisplay);
    elseif ismac
        backend = 'macos';
        data = nosleep_on_macos(keepDisplay);
    elseif isunix
        backend = 'linux';
        data = nosleep_on_linux(keepDisplay);
    else
        error('NoSleep:UnsupportedOS', 'Unsupported operating system.');
    end

    % Backend may fail and return [] or NaN to signal "no-op"
    if isempty(data) || (isnumeric(data) && isscalar(data) && isnan(data))
        handle = [];
        return;
    end

    % Handle is a simple struct storing backend and backend-specific data
    handle = struct( ...
        'backend', backend, ...
        'data',    data);

    % Register handle in session state
    nosleep_state('register', handle);
end
