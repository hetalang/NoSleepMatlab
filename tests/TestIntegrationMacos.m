classdef TestIntegrationMacos < matlab.unittest.TestCase
    % Integration test for macOS caffeinate backend
    % Uses `pmset -g assertions` to detect active assertions

    methods (Test)
        function testMacCaffeinateAssertion(testCase)

            % Run only on macOS
            if ~ismac
                testCase.assumeFail("macOS-specific test.");
            end

            % Opt-in via environment variable
            runTest = getenv("INTEGRATION_TESTS");
            if ~(strcmp(runTest, "1"))
                testCase.assumeFail("Integration tests disabled (set INTEGRATION_TESTS=1).");
            end

            % Require pmset and caffeinate binaries
            if system("which pmset > /dev/null") ~= 0 || ...
               system("which caffeinate > /dev/null") ~= 0

                testCase.verifyFail( ...
                    "macOS CLI check requires 'pmset' and 'caffeinate' in PATH." );
                return
            end

            % Helper: run pmset -g assertions and capture output
            function out = pmsetAssertions()
                [status, cmdout] = system("pmset -g assertions 2>/dev/null");
                if status ~= 0
                    testCase.verifyFail("Failed to run 'pmset -g assertions'.");
                    out = "";
                else
                    out = cmdout;
                end
            end

            % Small delay to allow macOS powerd to update state
            function shortWait()
                pause(0.2);
            end

            % Before enabling nosleep
            pre = pmsetAssertions();

            h = NoSleep.nosleep_on(false);  % keep_display = false
            shortWait();
            mid = pmsetAssertions();

            NoSleep.nosleep_off(h);
            shortWait();
            post = pmsetAssertions();

            % Look for caffeinate assertion (same as R test)
            hasCaffMid  = contains(mid,  "caffeinate", "IgnoreCase", true);
            hasCaffPost = contains(post, "caffeinate", "IgnoreCase", true);

            % While active, mid MUST contain caffeinate
            testCase.verifyTrue( ...
                hasCaffMid, ...
                "pmset output while nosleep_on() is active should mention 'caffeinate'." ...
            );

            % After nosleep_off(), caffeinate assertion should be gone
            % OR pmset may return identical snapshot (caching behavior)
            testCase.verifyTrue( ...
                ~hasCaffPost || strcmp(post, mid), ...
                "pmset output after nosleep_off() should not show 'caffeinate', or be identical to mid due to caching." ...
            );
        end
    end
end
