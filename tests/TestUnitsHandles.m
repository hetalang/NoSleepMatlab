classdef TestUnitsHandles < matlab.unittest.TestCase
    % API-level tests for NoSleep MATLAB toolbox
    
    methods (Test)
        function testNosleepOnReturnsHandleOrEmpty(testCase)
            % nosleep_on should return either [] or a valid handle struct
            h = NoSleep.nosleep_on();
            
            isEmptyHandle  = isempty(h);
            isValidHandle  = isstruct(h) && isfield(h, "backend") && isfield(h, "data");
            
            testCase.verifyTrue( ...
                isEmptyHandle || isValidHandle, ...
                "nosleep_on must return [] or a handle struct." ...
            );
            
            % nosleep_off([]) should be a no-op
            testCase.verifyWarningFree(@() NoSleep.nosleep_off([]));
            
            if ~isempty(h)
                % If handle is present, it can be safely turned off
                testCase.verifyWarningFree(@() NoSleep.nosleep_off(h));
            else
                % If backend is not available, global off must not error
                testCase.verifyWarningFree(@() NoSleep.nosleep_off());
            end
        end
        
        function testNosleepOffHandlesMissingNullWrongTypes(testCase)
            % No argument: global off
            testCase.verifyWarningFree(@() NoSleep.nosleep_off());
            
            % [] (NULL-equivalent) — no-op
            testCase.verifyWarningFree(@() NoSleep.nosleep_off([]));
            
            % Wrong type -> error
            testCase.verifyError( ...
                @() NoSleep.nosleep_off(123), ...
                "NoSleep:InvalidHandle" ... % сделай у себя такой ID в nosleep_off
            );
        end
        
        function testMultipleHandlesAndOffSemantics(testCase)
            h1 = NoSleep.nosleep_on();
            h2 = NoSleep.nosleep_on();
            
            if isempty(h1) || isempty(h2)
                % Backend not available: just ensure global off does not error
                testCase.verifyWarningFree(@() NoSleep.nosleep_off());
                return;
            end
            
            % Both should be valid handles
            testCase.verifyTrue(isstruct(h1) && isfield(h1,"backend"));
            testCase.verifyTrue(isstruct(h2) && isfield(h2,"backend"));
            
            % Turn off one handle
            testCase.verifyWarningFree(@() NoSleep.nosleep_off(h1));
            
            % Turn off the other one
            testCase.verifyWarningFree(@() NoSleep.nosleep_off(h2));
            
            % Repeated off on already turned-off handle should not error
            testCase.verifyWarningFree(@() NoSleep.nosleep_off(h2));
            
            % Create one more handle
            h3 = NoSleep.nosleep_on();
            if ~isempty(h3)
                % Global off must turn off all active and not error
                testCase.verifyWarningFree(@() NoSleep.nosleep_off());
            else
                % Backend not available, but API still must not crash
                testCase.verifyWarningFree(@() NoSleep.nosleep_off());
            end
        end
    end
end
