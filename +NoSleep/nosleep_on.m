function handle = nosleep_on(keep_display)
%NOSLEEP_ON Prevent system sleep while MATLAB code runs.
%
% Syntax:
%   handle = NoSleep.nosleep_on()
%   handle = NoSleep.nosleep_on(keep_display)
%
% Input:
%   keep_display (logical scalar, optional)
%     true  - also prevent display sleep
%     false - prevent only system sleep (default)
%
% Output:
%   handle (struct or [])
%     Backend handle used by NoSleep.nosleep_off(handle).
%     Returns [] if the backend is unavailable or could not be started.
%
% See also: NoSleep.nosleep_off, NoSleep.with_nosleep

    % Parse input
    if nargin == 0
        keepDisplay = false;
    elseif nargin == 1
        if ~(islogical(keep_display) && isscalar(keep_display))
            error("NoSleep:InvalidArgument", ...
                  "'keep_display' must be a logical scalar.");
        end
        keepDisplay = keep_display;
    else
        error("NoSleep:TooManyInputs", ...
              "nosleep_on accepts at most one logical argument.");
    end

    backend = '';
    data    = [];

    % OS detection and backend dispatch
    if ispc
        backend = 'windows';
        data    = nosleep_on_windows(keepDisplay);
    elseif ismac
        backend = 'macos';
        data    = nosleep_on_macos(keepDisplay);
    elseif isunix
        backend = 'linux';
        data    = nosleep_on_linux(keepDisplay);
    else
        error('NoSleep:UnsupportedOS', 'Unsupported operating system.');
    end

    % Backend may fail and return [] to signal "no-op"
    if isempty(data)
        handle = [];
        return;
    end

    % Create handle struct
    handle = struct( ...
        'backend', backend, ...
        'data',    data);

    % Register handle in session state
    nosleep_state('register', handle);
end
