clear all
clc

MAX31856_READ_REGISTER  = hex2dec('00');
MAX31856_WRITE_REGISTER = hex2dec('80');
MAX31856_LTCBH     = hex2dec('0C');    %High
MAX31856_LTCBM     = hex2dec('0D');    %Medium
MAX31856_LTCBL     = hex2dec('0E');    %Low

MAX31856_REGISTER_0     = hex2dec('00');
%bit_7 - Conversion Mode           -> 0
%bit_6 - One-Shot Mode             -> 0
%bit_5 - Desable Detect Error 1    -> 0
%bit_4 - Desable Detect Error 1    -> 0
%bit_3 - Cold-Juction Disable      -> 0
%bit_2 - Fault Mode                -> 0
%bit_1 - Fault Status Clear        -> 0
%bit_0 - 60/50Hz Filter Selection  -> 0

MAX31856_REGISTER_1     = hex2dec('01');
%bit_7 - Reserved                  -> 0
%bit_6 - Averaging Mode 2          -> 0
%bit_5 - Averaging Mode 1          -> 0
%bit_4 - Averaging Mode 0          -> 0
%bit_3 - Thermocouple Type 3       -> 0
%bit_2 - Thermocouple Type 2       -> 0
%bit_1 - Thermocouple Type 1       -> 1
%bit_0 - Thermocouple Type 0       -> 1

RPI = raspi();
enableSPI(RPI);
SPI = spidev(RPI,'CE0', 1, 4000000);

h = animatedline;
axis([0 100 0 100])

for n = 1:100
    writeRead(SPI,[bitor(MAX31856_REGISTER_0, MAX31856_WRITE_REGISTER), hex2dec('42')]);
    pause(.1);
    tC_high = writeRead(SPI,[bitor(MAX31856_LTCBH , MAX31856_READ_REGISTER), 0]);
    tC_middle = writeRead(SPI,[bitor(MAX31856_LTCBM , MAX31856_READ_REGISTER), 0]);
    tC_low = writeRead(SPI,[bitor(MAX31856_LTCBL , MAX31856_READ_REGISTER), 0]);

    tempC = int64(tC_high(2));
    tempC = bitsll(tempC,8);
    tempC = tempC + (int64(tC_middle(2)));
    tempC = bitsll(tempC,8);
    tempC = tempC + (int64(tC_low(2)));
    tempC = bitsrl(tempC, 5);
    temp_C = double(tempC);
    temp_C = (temp_C * 0.0078125);
    addpoints(h, n, temp_C);
    drawnow limitrate
end
clear RPI
clear SPI