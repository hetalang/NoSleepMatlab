classdef TestIntegrationWindows < matlab.unittest.TestCase
    % Integration test for Windows PowerRequest via powercfg /requests

    methods (Test)
        function testWindowsPowerRequest(testCase)

            % Run only on Windows
            if ~ispc
                testCase.applyFixture(matlab.unittest.fixtures.DisableWarningsFixture());
                testCase.assumeFail("Windows-specific test.");
            end

            % Opt-in via environment variable
            runTest = getenv("INTEGRATION_TESTS");
            if ~(strcmp(runTest, "1"))
                testCase.assumeFail("Integration test disabled (set INTEGRATION_TESTS=1).");
            end

            % Require powercfg
            [status, ~] = system("where powercfg");
            if status ~= 0
                testCase.verifyFail("powercfg not found in PATH.");
                return
            end

            % Helper function: run powercfg /requests and return output text
            function out = powercfgRequests()
                [status, cmdout] = system("powershell -NoProfile -Command ""powercfg /requests""");

                if status ~= 0
                    testCase.verifyFail("Failed to run 'powercfg /requests'.");
                    out = "";
                else
                    out = cmdout;
                end
            end

            % Small delay (Windows is slow updating request table)
            function shortWait()
                pause(0.2);
            end

            pre  = powercfgRequests();

            h = NoSleep.nosleep_on();
            shortWait();
            mid  = powercfgRequests();

            NoSleep.nosleep_off(h);
            shortWait();
            post = powercfgRequests();

            % Helper: detect typical execution request markers
            function tf = hasSignal(s)
                tf = contains(s, "EXECUTION", "IgnoreCase", true) || ...
                     contains(s, "System Required", "IgnoreCase", true) || ...
                     contains(s, "Display Required", "IgnoreCase", true) || ...
                     contains(s, "Legacy Kernel Caller", "IgnoreCase", true);
            end

            % Expectations:
            %  - mid should show the signal
            %  - pre and post ideally not
            if hasSignal(mid) && (~hasSignal(post) || strcmp(pre, post))
                testCase.verifyTrue(true);   % ok
            else
                testCase.verifyFail("Windows integration check failed: unexpected power request state.");
            end
        end
    end
end
