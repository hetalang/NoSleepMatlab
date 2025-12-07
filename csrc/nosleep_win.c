/*
 * nosleep_win.c
 *
 * Windows backend for NoSleep.mltbx using Power Request API.
 * Each call to create_request() creates a separate Power Request handle.
 *
 * MATLAB interface:
 *
 *   data = nosleep_win('create', keepDisplay);
 *   nosleep_win('clear', data);
 *
 * `data` is a struct returned to MATLAB containing an integer ID.
 * MEX internally stores HANDLEs in a static table.
 */

#include "mex.h"
#include <windows.h>

typedef struct {
    HANDLE h;
    BOOL   display;
    BOOL   active;
} RequestEntry;

#define MAX_REQUESTS 256
static RequestEntry requestTable[MAX_REQUESTS];
static int initialized = 0;

/* Utility: find free slot */
static int alloc_slot() {
    for (int i = 0; i < MAX_REQUESTS; i++) {
        if (!requestTable[i].active)
            return i;
    }
    return -1;
}

/* Utility: clear slot */
static void clear_slot(int id) {
    requestTable[id].active  = FALSE;
    requestTable[id].h       = NULL;
    requestTable[id].display = FALSE;
}

/* Final cleanup when MATLAB clears MEX */
static void cleanup(void) {
    for (int i = 0; i < MAX_REQUESTS; i++) {
        if (requestTable[i].active && requestTable[i].h != NULL) {
            PowerClearRequest(requestTable[i].h, PowerRequestSystemRequired);
            if (requestTable[i].display)
                PowerClearRequest(requestTable[i].h, PowerRequestDisplayRequired);
            CloseHandle(requestTable[i].h);
        }
        clear_slot(i);
    }
}

/* Create request */
mxArray* create_request(bool keepDisplay) {

    REASON_CONTEXT context;
    ZeroMemory(&context, sizeof(context));
    context.Version = POWER_REQUEST_CONTEXT_VERSION;
    context.Flags   = POWER_REQUEST_CONTEXT_SIMPLE_STRING;
    context.Reason.SimpleReasonString = L"Set by NoSleep MATLAB toolbox";

    HANDLE h = PowerCreateRequest(&context);
    if (h == NULL)
        return mxCreateDoubleScalar(mxGetNaN());

    if (!PowerSetRequest(h, PowerRequestSystemRequired)) {
        CloseHandle(h);
        return mxCreateDoubleScalar(mxGetNaN());
    }

    BOOL disp = FALSE;
    if (keepDisplay) {
        if (!PowerSetRequest(h, PowerRequestDisplayRequired)) {
            PowerClearRequest(h, PowerRequestSystemRequired);
            CloseHandle(h);
            return mxCreateDoubleScalar(mxGetNaN());
        }
        disp = TRUE;
    }

    int id = alloc_slot();
    if (id < 0) {
        PowerClearRequest(h, PowerRequestSystemRequired);
        if (disp)
            PowerClearRequest(h, PowerRequestDisplayRequired);
        CloseHandle(h);
        return mxCreateDoubleScalar(mxGetNaN());
    }

    requestTable[id].active  = TRUE;
    requestTable[id].h       = h;
    requestTable[id].display = disp;

    return mxCreateDoubleScalar((double)id);
}

/* Clear request */
void clear_request(int id) {
    if (id < 0 || id >= MAX_REQUESTS)
        return;

    if (!requestTable[id].active)
        return;

    HANDLE h = requestTable[id].h;

    if (h != NULL) {
        PowerClearRequest(h, PowerRequestSystemRequired);
        if (requestTable[id].display)
            PowerClearRequest(h, PowerRequestDisplayRequired);
        CloseHandle(h);
    }

    clear_slot(id);
}

/* MEX gateway */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[]) {

    if (!initialized) {
        mexAtExit(cleanup);
        memset(requestTable, 0, sizeof(requestTable));
        initialized = 1;
    }

    if (nrhs < 1 || !mxIsChar(prhs[0]))
        mexErrMsgTxt("First argument must be a command string ('create' or 'clear').");

    char cmd[16];
    mxGetString(prhs[0], cmd, sizeof(cmd));

    if (strcmp(cmd, "create") == 0) {
        if (nrhs < 2)
            mexErrMsgTxt("Missing keepDisplay argument.");
        bool keepDisplay = mxIsLogicalScalarTrue(prhs[1]);
        plhs[0] = create_request(keepDisplay);
        return;
    }

    if (strcmp(cmd, "clear") == 0) {
        if (nrhs < 2)
            mexErrMsgTxt("Missing request ID.");
        int id = (int) mxGetScalar(prhs[1]);
        clear_request(id);
        return;
    }

    mexErrMsgTxt("Unknown command.");
}
