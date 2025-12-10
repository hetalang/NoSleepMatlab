classdef TestIntegrationLinux < matlab.unittest.TestCase
    % Integration test for Linux systemd inhibitors using systemd-inhibit --list

    methods (Test)
        function testLinuxSystemdIntegration(testCase)

            % Run only on Linux
            if ~isunix || ismac
                testCase.assumeFail("Linux-specific test.");
            end

            % Opt-in via environment variable
            runTest = getenv("INTEGRATION_TESTS");
            if ~(strcmp(runTest, "1"))
                testCase.assumeFail("Integration tests disabled (set INTEGRATION_TESTS=1).");
            end

            % systemd-inhibit and loginctl must exist
            if system("which systemd-inhibit > /dev/null") ~= 0 || ...
               system("which loginctl > /dev/null") ~= 0

                testCase.verifyFail("systemd-inhibit and/or loginctl not found in PATH.");
                return
            end

            % Helper function: run systemd-inhibit --list and capture output
            function out = systemdInhibitList()
                [status, cmdout] = system("systemd-inhibit --list 2>/dev/null");
                if status ~= 0
                    testCase.verifyFail("Failed to run 'systemd-inhibit --list'.");
                    out = "";
                else
                    out = cmdout;
                end
            end

            % Small delay to give systemd time to update inhibitor state
            function shortWait()
                pause(0.2);
            end

            % Before
            pre = systemdInhibitList();

            h = NoSleep.nosleep_on();
            shortWait();
            mid = systemdInhibitList();

            NoSleep.nosleep_off(h);
            shortWait();
            post = systemdInhibitList();

            % Look for NoSleep marker (similar to R version)
            % In your backend you set:
            %   --who=NoSleep
            containsMid = contains(mid, "NoSleep", "IgnoreCase", true);
            containsPost = contains(post, "NoSleep", "IgnoreCase", true);

            % Check that it appears while active
            testCase.verifyTrue( ...
                containsMid, ...
                "systemd-inhibit --list while nosleep_on() is active should mention 'NoSleep'." ...
            );

            % …and disappears after nosleep_off()
            testCase.verifyFalse( ...
                containsPost, ...
                "systemd-inhibit --list after nosleep_off() should not mention 'NoSleep'." ...
            );

            % State must actually change between pre and mid
            testCase.verifyFalse( ...
                strcmp(pre, mid), ...
                "systemd-inhibit --list output should change when inhibitor is active." ...
            );
        end
    end
end
