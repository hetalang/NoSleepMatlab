classdef TestUnitsSimple < matlab.unittest.TestCase
    % Tests for the NoSleep MATLAB toolbox
    
    methods (Test)
        
        function testBasicAPI(testCase)
            % nosleep_on / nosleep_off should run without errors
            NoSleep.nosleep_on();
            testCase.verifyWarningFree(@() NoSleep.nosleep_off());
            
            % with_nosleep executes block and returns value
            result = NoSleep.with_nosleep(@() (2 + 2));
            testCase.verifyEqual(result, 4);
        end
        
        
        function testWithError(testCase)
            % with_nosleep must restore state even if error inside func()
            
            testCase.verifyError( ...
                @() NoSleep.with_nosleep(@() error("fail inside block")), ...
                ?MException);    % or a specific ID
            % After exception nosleep_off must still be callable
            testCase.verifyWarningFree(@() NoSleep.nosleep_off());
        end
        
        
        function testKeepDisplayOption(testCase)
            % nosleep_on(true) should not crash
            NoSleep.nosleep_on(true);
            testCase.verifyWarningFree(@() NoSleep.nosleep_off());
        end
        
    end
end
