classdef PWMServoDriver < arduinoio.LibraryBase & matlab.mixin.CustomDisplay
    % PWMServoDriver Create a PWMServoDriver device object
    %
    % To begin with connect to an Arduino Uno board on COM port 3 on Windows (change as needed)
    % a = arduino('COM3','Uno','Libraries','Adafruit/PWMServoDriver');
    %
	% Create the sensor object
    % pwmShield = addon(a,'Adafruit/PWMServoDriver');

    properties(Access = private, Constant = true)
        CREATE_MOTOR_SHIELD = hex2dec('00')
        DELETE_MOTOR_SHIELD = hex2dec('01')
        SET_PWM_SERVO_MOTOR = hex2dec('02')
    end

    properties(SetAccess = immutable)
        I2CAddress = hex2dec('7F');
        PWMFrequency = 1600;
    end
    
    properties(Access = private)
        Bus
        CountCutOff
        ShieldSlotNum
    end
    
    properties(Access = private)
        ResourceOwner = 'AdafruitPWMServoDriver';
        MinI2CAddress = hex2dec('40');  
        MaxI2CAddress = hex2dec('7F');   
    end
    
    % Include all the source files
    properties(Access = protected, Constant = true)
        LibraryName = 'Adafruit/PWMServoDriver'
        DependentLibraries = {'Servo', 'I2C'}
        ArduinoLibraryHeaderFiles = 'Adafruit_PWMServoDriver/Adafruit_PWMServoDriver.h'
		CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'PWMServoDriverBase.h')
        CppClassName = 'PWMServoDriverBase'
    end
    
    %% Constructor
    methods(Hidden, Access = public)
        function obj = PWMServoDriver(parentObj, varargin)
            obj.Parent = parentObj;
            
            if ismember(obj.Parent.Board, {'Uno', 'Leonardo'}) % shield limit 
                obj.CountCutOff = 4;
            else
                obj.CountCutOff = 32;
            end
            
            count = incrementResourceCount(obj.Parent, obj.ResourceOwner);
            if count > obj.CountCutOff
                obj.localizedError('MATLAB:arduinoio:general:maxAddonLimit',...
                    num2str(obj.CountCutOff),...
                    obj.ResourceOwner,...
                    obj.Parent.Board);
            end
            
            try
                p = inputParser;
                addParameter(p, 'I2CAddress', hex2dec('7F'));
                addParameter(p, 'PWMFrequency', 1600); %%%% 60 hz?
                parse(p, varargin{:});
            catch
                obj.localizedError('MATLAB:arduinoio:general:invalidNVPropertyName',...
                    obj.ResourceOwner, ...
                    arduinoio.internal.renderCellArrayOfCharVectorsToCharVector(p.Parameters, ', '));
            end
            
            address = validateAddress(obj, p.Results.I2CAddress);
            try
                i2cAddresses = getSharedResourceProperty(parentObj, obj.ResourceOwner, 'i2cAddresses');
            catch
                i2cAddresses = [];
            end
            if ismember(address, i2cAddresses)
                obj.localizedError('MATLAB:arduinoio:general:conflictI2CAddress', ...
                    num2str(address),...
                    dec2hex(address));
            end
            i2cAddresses = [i2cAddresses address];
            setSharedResourceProperty(parentObj, obj.ResourceOwner, 'i2cAddresses', i2cAddresses);
            obj.I2CAddress = address;
            
%             frequency = arduinoio.internal.validateDoubleParameterRanged('PWM frequency', p.Results.PWMFrequency, 0, 2^15-1, 'Hz');
%             obj.PWMFrequency = frequency;
            
            configureI2C(obj);
            
            obj.ShieldSlotNum = getFreeResourceSlot(obj.Parent, obj.ResourceOwner);
            createMotorShield(obj);
            
            setSharedResourceProperty(parentObj, 'I2C', 'I2CIsUsed', true);
        end
    end
    
    %% Destructor
    methods (Access=protected)
        function delete(obj)
            originalState = warning('off','MATLAB:class:DestructorError');
            try
                parentObj = obj.Parent;
                i2cAddresses = getSharedResourceProperty(parentObj, obj.ResourceOwner, 'i2cAddresses');
                if ~isempty(i2cAddresses)
                    if ~isempty(obj.I2CAddress) 
                        % Can be empty if failed during construction
                        i2cAddresses(i2cAddresses==obj.I2CAddress) = [];
                    end
                end
                setSharedResourceProperty(parentObj, obj.ResourceOwner, 'i2cAddresses', i2cAddresses);
                decrementResourceCount(obj.Parent, obj.ResourceOwner);
                clearResourceSlot(parentObj, obj.ResourceOwner, obj.ShieldSlotNum);
                deleteMotorShield(obj);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
            warning(originalState.state, 'MATLAB:class:DestructorError');
        end
    end
    
    %% Public methods
    methods (Access = public)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%METHODSS
        function setPWM(obj,motnum,lowPWM, highPWM)
            commandID = obj.SET_PWM_SERVO_MOTOR;     
            try
                if (nargin < 2)
                    obj.localizedError('MATLAB:minrhs');
                end
                % validate values in range pulses
%                 arduinoio.internal.validateDoubleParameterRanged('lowPWM', lowPWM, 100, 150);
%                 arduinoio.internal.validateDoubleParameterRanged('highPWM', highPWM, 500, 650);
                
                %value = uint8(180*value);
                params = [obj.ShieldSlotNum, motnum, lowPWM, highPWM];
                sendCommandCustom(obj, obj.LibraryName, commandID, params');
            catch e
                throwAsCaller(e);
            end
        end
    end
    
    %% Private methods
    methods (Access = private)
        function createMotorShield(obj)        
            commandID = obj.CREATE_MOTOR_SHIELD;
            frequency = typecast(uint16(obj.PWMFrequency), 'uint8');
            data = [uint8(obj.I2CAddress), frequency];
            sendCommandCustom(obj, obj.LibraryName, commandID, data');
        end
        
        function deleteMotorShield(obj)
            commandID = obj.DELETE_MOTOR_SHIELD;
            
            params = [];
            sendCommandCustom(obj, obj.LibraryName, commandID, params);
        end
    end
    
    %% Helper method to related classes
    methods (Access = {?arduinoioaddons.adafruit.Servo})
        function output = sendShieldCommand(obj, commandID, inputs, timeout)
            switch nargin
                case 3
                    output = sendCommandCustom(obj, obj.LibraryName, commandID, inputs);
                case 4
                    output = sendCommandCustom(obj, obj.LibraryName, commandID, inputs, timeout);
                otherwise
            end
        end
    end
    
    methods(Access = private)
        function addr = validateAddress(obj, address)
            % accept string type address but convert to character vector
            if isstring(address)
                address = char(address);
            end
            if ~ischar(address)
                try
                    addr = arduinoio.internal.validateIntParameterRanged('address', address, obj.MinI2CAddress, obj.MaxI2CAddress);
                    return;
                catch
                    printableAddress = false;
                    try
                        printableAddress = (numel(num2str(address)) == 1);
                    catch
                    end
                    
                    if printableAddress
                        obj.localizedError('MATLAB:arduinoio:general:invalidI2CAddress', num2str(address), num2str(obj.MinI2CAddress), num2str(obj.MaxI2CAddress));
                    else
                        obj.localizedError('MATLAB:arduinoio:general:invalidI2CAddressType');
                    end
                end

            else            
                tmpAddr = address;
                
                try
                    index = strfind(lower(tmpAddr), '0x');
                    if index == 1
                        tmpAddr = tmpAddr(3:end);
                    elseif strcmpi(tmpAddr(end), 'h')
                        tmpAddr(end) = [];
                    end
                    addressInDec = hex2dec(tmpAddr);
                catch 
                    obj.localizedError('MATLAB:arduinoio:general:invalidI2CAddress', address, num2str(obj.MinI2CAddress), num2str(obj.MaxI2CAddress));
                end
            
                if addressInDec < obj.MinI2CAddress || addressInDec > obj.MaxI2CAddress
                    obj.localizedError('MATLAB:arduinoio:general:invalidI2CAddress', address, num2str(obj.MinI2CAddress), num2str(obj.MaxI2CAddress));
                end
            end
            
            addr = addressInDec;
        end
    
        function configureI2C(obj)
            parentObj = obj.Parent;
            I2CTerminals = parentObj.getI2CTerminals();
            
            if ~strcmp(parentObj.Board, 'Due')
                obj.Bus = 0;
                resourceOwner = '';
                sda = parentObj.getPinsFromTerminals(I2CTerminals(obj.Bus*2+1)); sda = sda{1};
                configurePinResource(parentObj, sda, resourceOwner, 'I2C', false);
                scl = parentObj.getPinsFromTerminals(I2CTerminals(obj.Bus*2+2)); scl = scl{1};
                configurePinResource(parentObj, scl, resourceOwner, 'I2C', false);
                obj.Pins = {sda scl};
            else
                obj.Bus = 1;
                obj.Pins = {'SDA1', 'SCL1'};
            end
        end
    end
    
    %% Protected methods
    methods(Access = protected)
        function output = sendCommandCustom(obj, libName, commandID, inputs, timeout)
            inputs = [obj.ShieldSlotNum-1; inputs];
            if nargin > 4
                [output, ~] = sendCommand(obj, libName, commandID, inputs, timeout);
            else
                [output, ~] = sendCommand(obj, libName, commandID, inputs);
            end
        end
        
        function displayScalarObject(obj)
            header = getHeader(obj);
            disp(header);
            
            % Display main options
            pins = [obj.Pins{1} '(SDA), ' obj.Pins{2} '(SCL)'];
            fprintf('            Pins: %-15s\n', pins);
            fprintf('      I2CAddress: %-1d (0x%02s)\n', obj.I2CAddress, dec2hex(obj.I2CAddress));
            fprintf('    PWMFrequency: %.2d (Hz)\n', obj.PWMFrequency);
            fprintf('\n');
                  
            % Allow for the possibility of a footer.
            footer = getFooter(obj);
            if ~isempty(footer)
                disp(footer);
            end
        end
    end
end
