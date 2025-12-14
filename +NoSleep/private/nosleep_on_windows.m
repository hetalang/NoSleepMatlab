function data = nosleep_on_windows(keep_display)
% Windows backend wrapper. Returns struct with request ID.
%
% keep_display: logical scalar

    if nargin < 1
        keep_display = false;
    end

    if ~islogical(keep_display)
        error("NoSleep: 'keep_display' must be logical.");
    end

    % MEX call: returns request ID or NaN
    id = nosleep_win('create', keep_display);

    if isnan(id)
        warning("NoSleep: 'PowerRequest' not found; Windows backend is not available.");
        data = [];
        return;
    end

    data = struct("id", id);
end
