**www.ti.com** ............................................................................................................................................... SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 

# **Low Power Digital Temperature Sensor With SMBus™/Two-Wire Serial Interface in SOT563** 

###### **1FEATURES** 

- **23** • **TINY SOT563 PACKAGE** 

- **ACCURACY: 0.5°C (–25°C to +85°C)** 

- **LOW QUIESCENT CURRENT: 10** µ **A Active (max) 1** µ **A Shutdown (max)** 

- **SUPPLY RANGE: 1.4V to 3.6V** 

- **RESOLUTION: 12 Bits** 

- **DIGITAL OUTPUT: Two-Wire Serial Interface** 

##### **APPLICATIONS** 

- **PORTABLE AND BATTERY-POWERED APPLICATIONS** 

##### **DESCRIPTION** 

The TMP102 is a two-wire, serial output temperature sensor available in a tiny SOT563 package. Requiring no external components, the TMP102 is capable of reading temperatures to a resolution of 0.0625°C. 

The TMP102 features SMBus and two-wire interface compatibility, and allows up to four devices on one bus. It also features an SMB alert function. 

The TMP102 is ideal for extended temperature measurement in a variety of communication, computer, consumer, environmental, industrial, and instrumentation applications. The device is specified for operation over a temperature range of –40°C to +125°C. 

- **POWER-SUPPLY TEMPERATURE MONITORING** 

- **COMPUTER PERIPHERAL THERMAL PROTECTION** 

- **NOTEBOOK COMPUTERS** 

- **BATTERY MANAGEMENT** 

- **OFFICE MACHINES** 

- **THERMOSTAT CONTROLS** 

- **ELECTROMECHANICAL DEVICE TEMPERATURES** 

- **GENERAL TEMPERATURE MEASUREMENTS: Industrial Controls Test Equipment** 

###### **Medical Instrumentations** 



<!-- Start of picture text -->
Temperature<br>Diode<br>1 Control 6<br>SCL Temp. SDA<br>Logic<br>Sensor<br>��<br>2 Serial 5<br>GND A/D V+<br>Interface<br>Converter<br>3 Config. 4<br>ALERT OSC and�Temp. ADD0<br>Register<br>TMP102<br><!-- End of picture text -->

Please be aware that an important notice concerning availability, standard warranty, and use in critical applications of Texas Instruments semiconductor products and disclaimers thereto appears at the end of this data sheet. 

> 2SMBus is a trademark of Intel, Inc. 

> 3All other trademarks are the property of their respective owners. 

#### **TMP102** 

SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... **www.ti.com** 



This integrated circuit can be damaged by ESD. Texas Instruments recommends that all integrated circuits be handled with appropriate precautions. Failure to observe proper handling and installation procedures can cause damage. 

ESD damage can range from subtle performance degradation to complete device failure. Precision integrated circuits may be more susceptible to damage because very small parametric changes could cause the device not to meet its published specifications. 

###### **ORDERING INFORMATION**<sup>**(1)**</sup> 

|**PRODUCT**|**PACKAGE-LEAD**|**PACKAGE DESIGNATOR**|**PACKAGE MARKING**|
|---|---|---|---|
|TMP102|SOT563|DRL|CBZ|



- (1) For the most current package and ordering information, see the Package Option Addendum at the end of this document, or see the TI web site at www.ti.com. 

###### **ABSOLUTE MAXIMUM RATINGS**<sup>**(1)**</sup> 

|**PARAMETER**||**TMP102**|**UNIT**|
|---|---|---|---|
|Supply Voltage||3.6|V|
|Input Voltage<sup>(2)</sup>||–0.5 to +3.6|V|
|Operating Temp|erature|–55 to +150|°C|
|Storage Temper|ature|–60 to +150|°C|
|Junction Tempe|rature|+150|°C|
||Human Body Model (HBM)|2000|V|
|ESD Rating|Charged Device Model (CDM)|1000|V|
||Machine Model (MM)|200|V|



- (1) Stresses above these ratings may cause permanent damage. Exposure to absolute maximum conditions for extended periods may degrade device reliability. These are stress ratings only, and functional operation of the device at these or any other conditions beyond those specified is not supported. 

- (2) Input voltage rating applies to all TMP102 input voltages. 

###### **PIN CONFIGURATION** 



<!-- Start of picture text -->
DRL Package<br>SOT563<br>Top View<br>SCL 1 6 SDA<br>GND 2 5 V+<br>ALERT 3 CBZ 4 ADD0<br><!-- End of picture text -->

###### **ELECTRICAL CHARACTERISTICS** 

At TA = +25°C and VS = +1.4V to +3.6V, unless otherwise noted. 

|||||**TMP102**|||
|---|---|---|---|---|---|---|
|**PARAMETER**||**CONDITIONS**|**MIN**|**TYP**|**MAX**|**UNIT**|
|**TEMPERATURE INPUT**|||||||
|Range|||–40||+125|°C|
|Accuracy (Temperature Error)||–25°C to +85°C||0.5|2|°C|
|||–40°C to +125°C||1|3|°C|
|vs Supply||||0.2|0.5|°C/V|
|Resolution||||0.0625||°C|
|**DIGITAL INPUT/OUTPUT**|||||||
|Input Logic Levels:|||||||
|VIH|||0.7 (V+)||3.6|V|
|VIL|||–0.5||0.3 (V+)|V|
|Input Current|IIN|0 < VIN < 3.6V|||1|µA|
|Output Logic Levels:|||||||
|VOLSDA||V+ > 2V, IOL= 3mA|0||0.4|V|
|||V+ < 2V, IOL= 3mA|0||0.2 (V+)|V|
|VOLALERT||V+ > 2V, IOL= 3mA|0||0.4|V|
|||V+ < 2V, IOL= 3mA|0||0.2 (V+)|V|
|Resolution||||12||Bit|
|Conversion Time||||26|35|ms|
|Conversion Modes||CR1 = 0, CR0 = 0||0.25||Conv/s|
|||CR1 = 0, CR0 = 1||1||Conv/s|
|||CR1 = 1, CR0 = 0 (default)||4||Conv/s|
|||CR1 = 1, CR0 = 1||8||Conv/s|
|Timeout Time||||30|40|ms|
|**POWER SUPPLY**|||||||
|Operating Supply Range|||+1.4||+3.6|V|
|Quiescent Current|IQ|Serial Bus Inactive, CR1 = 1, CR0 = 0 (default)||7|10|µA|
|||Serial Bus Active, SCL Frequency = 400kHz||15||µA|
|||Serial Bus Active, SCL Frequency = 3.4MHz||85||µA|
|Shutdown Current|ISD|Serial Bus Inactive||0.5|1|µA|
|||Serial Bus Active, SCL Frequency = 400kHz||10||µA|
|||Serial Bus Active, SCL Frequency = 3.4MHz||80||µA|
|**TEMPERATURE RANGE**|||||||
|Specified Range|||–40||+125|°C|
|Operating Range|||–55||+150|°C|
|Thermal Resistance, SOT563|θJA|||260||°C/W|



###### **TYPICAL CHARACTERISTICS** 

At TA = +25°C and V+ = 3.3V, unless otherwise noted. 



<!-- Start of picture text -->
QUIESCENT CURRENT vs TEMPERATURE<br>(4 Conversions per Second) SHUTDOWN CURRENT vs TEMPERATURE<br>20 10<br>18 9<br>16 8<br>14 7<br>12 6<br>10 5<br>3.6V�Supply 3.6V�Suppl y<br>8 4<br>6 3<br>1.4V�Supply<br>4 2<br>1.4V�Supply<br>2 1<br>0 0<br>�60 �40 �20 0 20 40 60 80 100 120 140 160 �60 �40 �20 0 20 40 60 80 100 120 140 160<br>Temperature�(�C) Temperature�(�C)<br>Figure 1. Figure 2.<br>QUIESCENT CURRENT vs BUS FREQUENCY<br>CONVERSION TIME vs TEMPERATURE (Temperature at 3.3V Supply)<br>40 100<br>38 90<br>36 80<br>34 70<br>32 60<br>1.4V�Supply<br>30 50<br>28 40 +125�C<br>26 3.6V�Supply 30 +25�C �55�C<br>24 20<br>22 10<br>20 0<br>�60 �40 �20 0 20 40 60 80 100 120 140 160 1k 10k 100k 1M 10M<br>Temperature�(�C) Bus�Frequency�(Hz)<br>Figure 3. Figure 4.<br>TEMPERATURE ERROR vs TEMPERATURE TEMPERATURE ERROR AT +25°C<br>2.0<br>1.5<br>1.0<br>0.5<br>0<br>�0.5<br>�1.0<br>�1.5<br>�2.0<br>�60 �40 �20 0 20 40 60 80 100 120 140 160<br>Temperature�(�C)<br>Temperature�Error�(�C)<br>Figure 5. Figure 6.<br>(A)�<br>IQ<br>(A)� (A)�<br>IQ ISD<br>Conversion�Time�(ms)<br>�<br>Population<br>C)Temperature�Error�(<br>0.45� 0.35� 0.25� 0.15� 0.05� 0.05 0.15 0.25 0.35 0.45<br><!-- End of picture text -->

###### **APPLICATION INFORMATION** 

The TMP102 is a digital temperature sensor that is optimal for thermal-management and thermalprotection applications. The TMP102 is two-wire- and SMBus interface-compatible, and is specified over a temperature range of –40°C to +125°C. Pull-up resistors are required on SCL, SDA, and ALERT. A 0.01µF bypass capacitor is recommended, as shown in Figure 7. 



<!-- Start of picture text -->
V+<br>0.01�F<br>5<br>SCL 1 4<br>To ADD0<br>Two-Wire SDA 6 TMP102 3 ALERT<br>Controller<br>(Output)<br>2<br>NOTE:�SCL,�SDA,�and�ALERT<br>pins�require�pull-up�resistors.<br>GND<br><!-- End of picture text -->

**Figure 7. Typical Connections** 

The temperature sensor in the TMP102 is the chip itself. Thermal paths run through the package leads, as well as the plastic package. The lower thermal resistance of metal causes the leads to provide the primary thermal path. 

To maintain accuracy in applications requiring air or surface temperature measurement, care should be taken to isolate the package and leads from ambient air temperature. A thermally-conductive adhesive is helpful in achieving accurate surface temperature measurement. 

###### **POINTER REGISTER** 

Figure 8 shows the internal register structure of the TMP102. The 8-bit Pointer Register of the device is used to address a given data register. The Pointer Register uses the two LSBs (see Table 11) to identify which of the data registers should respond to a read or write command. Table 1 identifies the bits of the Pointer Register byte. During a write command, P2 through P7 must always be '0'. Table 2 describes the pointer address of the registers available in the TMP102. Power-up reset value of P1/P0 is '00'. By default, the TMP102 reads the temperature on power-up. 



<!-- Start of picture text -->
Pointer<br>Register<br>Temperature<br>Register<br>SCL<br>Configuration<br>Register<br>I/O<br>Control<br>Interface<br>TLOW<br>Register<br>SDA<br>THIGH<br>Register<br><!-- End of picture text -->

**Figure 8. Internal Register Structure** 

**Table 1. Pointer Register Byte** 

|**P7**|**P6**|**P5**|**P4**|**P3**|**P2**|**P1**<br>**P0**|
|---|---|---|---|---|---|---|
|0|0|0|0|0|0|Register Bits|



**Table 2. Pointer Addresses** 

|**P1**|**P0**|**REGISTER**|
|---|---|---|
|0|0|Temperature Register (Read Only)|
|0|1|Configuration Register (Read/Write)|
|1|0|TLOWRegister (Read/Write)|
|1|1|THIGHRegister (Read/Write)|



SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... **www.ti.com** 

###### **TEMPERATURE REGISTER** 

The Temperature Register of the TMP102 is configured as a 12-bit, read-only register (Configuration Register EM bit = '0', see the _Extended Mode_ section), or as a 13-bit, read-only register (Configuration Register EM bit = '1') that stores the output of the most recent conversion. Two bytes must be read to obtain data, and are described in Table 3 and Table 4. Note that byte 1 is the most significant byte, followed by byte 2, the least significant byte. The first 12 bits (13 bits in Extended mode) are used to indicate temperature. The least significant byte does not have to be read if that information is not needed. The data format for temperature is summarized in Table 5 and Table 6. One LSB equals 0.0625°C. Negative numbers are represented in binary twos complement format. Following power-up or reset, the Temperature Register will read 0°C until the first conversion is complete. Bit D0 of byte 2 

indicates Normal mode (EM bit = '0') or Extended mode (EM bit = '1') and can be used to distinguish between the two temperature register data formats. The unused bits in the Temperature Register always read '0'. 

**Table 3. Byte 1 of Temperature Register**<sup>**(1)**</sup> 

|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|---|---|---|---|---|---|---|---|
|T11|T10|T9|T8|T7|T6|T5|T4|
|(T12)|(T11)|(T10)|(T9)|(T8)|(T7)|(T6)|(T5)|



(1) Extended mode 13-bit configuration shown in parenthesis. 

###### **Table 4. Byte 2 of Temperature Register**<sup>**(1)**</sup> 

|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|---|---|---|---|---|---|---|---|
|T3|T2|T1|T0|0|0|0|0|
|(T4)|(T3)|(T2)|(T1)|(T0)|(0)|(0)|(1)|



(1) Extended mode 13-bit configuration shown in parenthesis. 

**Table 5. 12-Bit Temperature Data Format**<sup>**(1)**</sup> 

|**TEMPERATURE (°C)**|**DIGITAL OUTPUT (BINARY)**|**HEX**|
|---|---|---|
|128|0111 1111 1111|7FF|
|127.9375|0111 1111 1111|7FF|
|100|0110 0100 0000|640|
|80|0101 0000 0000|500|
|75|0100 1011 0000|4B0|
|50|0011 0010 0000|320|
|25|0001 1001 0000|190|
|0.25|0000 0000 0100|004|
|0|0000 0000 0000|000|
|–0.25|1111 1111 1100|FFC|
|–25|1110 0111 0000|E70|
|–55|1100 1001 0000|C90|



(1) The resolution for the Temp ADC in Internal Temperature mode is 0.0625°C/count. 

For positive temperatures (for example, +50°C): 

Twos complement is not performed on positive numbers. Therefore, simply convert the number to binary code with the 12-bit, left-justified format, and MSB = 0 to denote a positive sign. 

Example: (+50°C)/(0.0625°C/count) = 800 = 320h = 0011 0010 0000 

For negative temperatures (for example, –25°C): 

Generate the twos complement of a negative number by complementing the absolute value binary number and adding 1. Denote a negative number with MSB = 1. 

Example: (|–25°C|)/(0.0625°C/count) = 400 = 190h = 0001 1001 0000 Twos complement format: 1110 0110 1111 + 1 = 1110 0111 0000 

**Table 6. 13-Bit Temperature Data Format** 

|**TEMPERATURE (°C)**|**DIGITAL OUTPUT (BINARY)**|**HEX**|
|---|---|---|
|150|0 1001 0110 0000|0960|
|128|0 1000 0000 0000|0800|
|127.9375|0 0111 1111 1111|07FF|
|100|0 0110 0100 0000|0640|
|80|0 0101 0000 0000|0500|
|75|0 0100 1011 0000|04B0|
|50|0 0011 0010 0000|0320|
|25|0 0001 1001 0000|0190|
|0.25|0 0000 0000 0100|0004|
|0|0 0000 0000 0000|0000|
|–0.25|1 1111 1111 1100|1FFC|
|–25|1 1110 0111 0000|1E70|
|–55|1 1100 1001 0000|1C90|



###### **CONFIGURATION REGISTER** 

The Configuration Register is a 16-bit read/write register used to store bits that control the operational modes of the temperature sensor. Read/write operations are performed MSB first. The format and power-up/reset value of the Configuration Register is shown in Table 7. For compatibility, the first byte corresponds to the Configuration Register in the TMP75 and TMP275. All registers are updated byte by byte. 

**Table 7. Configuration and Power-Up/Reset Format** 

|**BYTE**|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|---|---|---|---|---|---|---|---|---|
|1|OS|R1|R0|F1|F0|POL|TM|SD|
||0|1|1|0|0|0|0|0|
||CR1|CR0|AL|EM|0|0|0|0|
|2|1|0|1|0|0|0|0|0|



###### **EXTENDED MODE (EM)** 

The Extended mode bit configures the device for Normal mode operation (EM = 0) or Extended mode operation (EM = 1). In Normal mode, the Temperature Register and highand low-limit registers use a 12-bit data format. Normal mode is used to make the TMP102 compatible with the TMP75. Extended mode (EM = 1) allows measurement of temperatures above +128°C by configuring the Temperature Register, and highand low-limit registers, for 13-bit data format. 

###### **ALERT (AL Bit)** 

The AL bit is a read-only function. Reading the AL bit will provide information about the comparator mode status. The state of the POL bit inverts the polarity of data returned from the AL bit. For POL = 0, the AL bit will read as '1' until the temperature equals or exceeds THIGH for the programmed number of consecutive faults, causing the AL bit to read as '0'. The AL bit will continue to read as '0' until the temperature falls below TLOW for the programmed number of consecutive faults, when it will again read as '1'. The status of the TM bit does not affect the status of the AL bit. 

###### **CONVERSION RATE** 

The conversion rate bits, CR1 and CR0, configure the TMP102 for conversion rates of 8Hz, 4Hz, 1Hz, or 0.25Hz. The default rate is 4Hz. The TMP102 has a typical conversion time of 26ms. To achieve different conversion rates, the TMP102 makes a conversion and after that powers down and waits for the appropriate delay set by CR1 and CR0. Table 8 shows the settings for CR1 and CR0. 

**Table 8. Conversion Rate Settings** 

|**CR1**|**CR0**|**CONVERSION RATE**|
|---|---|---|
|0|0|0.25Hz|
|0|1|1Hz|
|1|0|4Hz (default)|
|1|1|8Hz|



SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... **www.ti.com** 

After power-up or general-call reset, the TMP102 immediately starts a conversion, as shown in Figure 9. The first result is available after 26ms (typical). The active quiescent current during conversion is 40µA (typical at +27°C). The quiescent current during delay is 2.2µA (typical at +27°C). 



<!-- Start of picture text -->
Delay (1)<br>26ms<br>26ms<br>Startup Start�of<br>Conversion<br>NOTE:�(1)�Delay�is�set�by�CR1�and�CR0.<br><!-- End of picture text -->

**Figure 9. Conversion Start** 

###### **SHUTDOWN MODE (SD)** 

The Shutdown mode bit saves maximum power by shutting down all device circuitry other than the serial interface, reducing current consumption to typically less than 0.5µA. Shutdown mode is enabled when the SD bit is '1'; the device shuts down when current conversion is completed. When SD is equal to '0', the device maintains a continuous conversion state. 

###### **THERMOSTAT MODE (TM)** 

The Thermostat mode bit indicates to the device whether to operate in Comparator mode (TM = 0) or Interrupt mode (TM = 1). For more information on comparator and interrupt modes, see the _High- and Low-Limit Registers_ section. 

###### **POLARITY (POL)** 

The Polarity bit allows the user to adjust the polarity of the ALERT pin output. If POL = 0, the ALERT pin will be active low, as shown in Figure 10. For POL = 1, the ALERT pin will be active high, and the state of the ALERT pin is inverted. 



<!-- Start of picture text -->
THIGH<br>Measured<br>Temperature<br>TLOW<br>TMP102  ALERT�PIN<br>(Comparator�Mode)<br>POL�=�0<br>TMP102  ALERT�PIN<br>(Interrupt�Mode)<br>POL�=�0<br>TMP102  ALERT�PIN<br>(Comparator�Mode)<br>POL�=�1<br>TMP102  ALERT�PIN<br>(Interrupt�Mode)<br>POL�=�1<br>Read Read Read<br>Time<br><!-- End of picture text -->

**Figure 10. Output Transfer Function Diagrams** 

###### **FAULT QUEUE (F1/F0)** 

A fault condition exists when the measured temperature exceeds the user-defined limits set in the THIGH and TLOW registers. Additionally, the number of fault conditions required to generate an alert may be programmed using the fault queue. The fault queue is provided to prevent a false alert as a result of environmental noise. The fault queue requires consecutive fault measurements in order to trigger the alert function. Table 9 defines the number of measured faults that may be programmed to trigger an alert condition in the device. For THIGH and TLOW register format and byte order, see the _High- and Low-Limit Registers_ section. 

**Table 9. TMP102 Fault Settings** 

|**F1**|**F0**|**CONSECUTIVE FAULTS**|
|---|---|---|
|0|0|1|
|0|1|2|
|1|0|4|
|1|1|6|



**www.ti.com** ............................................................................................................................................... SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 

###### **CONVERTER RESOLUTION (R1/R0)** 

R1/R0 are read-only bits. The TMP102 converter resolution is set on start up to '11'. This sets the temperature register to a 12 bit-resolution. 

###### **ONE-SHOT/CONVERSION READY (OS)** 

The TMP102 features a One-Shot Temperature Measurement mode. When the device is in Shutdown mode, writing a ‘1’ to the OS bit starts a single temperature conversion. During the conversion, the OS bit reads '0'. The device returns to the shutdown state at the completion of the single conversion. After the conversion, the OS bit reads '1'. This feature is useful for reducing power consumption in the TMP102 when continuous temperature monitoring is not required. 

As a result of the short conversion time, the TMP102 can achieve a higher conversion rate. A single conversion typically takes 26ms and a read can take place in less than 20µs. When using One-Shot mode, 30 or more conversions per second are possible. 

###### **HIGH- AND LOW-LIMIT REGISTERS** 

In Comparator mode (TM = 0), the ALERT pin becomes active when the temperature equals or exceeds the value in THIGH and generates a consecutive number of faults according to fault bits F1 and F0. The ALERT pin remains active until the temperature falls below the indicated TLOW value for the same number of faults. 

In Interrupt mode (TM = 1), the ALERT pin becomes active when the temperature equals or exceeds the value in THIGH for a consecutive number of fault conditions (as shown in Table 9). The ALERT pin remains active until a read operation of any register occurs, or the device successfully responds to the SMBus Alert Response address. The ALERT pin will also be cleared if the device is placed in Shutdown mode. Once the ALERT pin is cleared, it becomes active again only when temperature falls below TLOW, and remains active until cleared by a read operation of any register or a successful response to the SMBus Alert Response address. Once the ALERT pin is cleared, the above cycle repeats, with the ALERT pin becoming active when the temperature equals or exceeds THIGH. The ALERT pin can also be cleared by resetting the device with the General Call Reset command. This action also clears the state of the internal registers in the device, returning the device to Comparator mode (TM = 0). 

Both operational modes are represented in Figure 10. Table 10 and Table 11 describe the format for the THIGH and TLOW registers. Note that the most significant byte is sent first, followed by the least significant byte. Power-up reset values for THIGH and TLOW are: THIGH = +80°C and TLOW = +75°C. The format of the data for THIGH and TLOW is the same as for the Temperature Register. 

**Table 10. Bytes 1 and 2 of THIGH Register**<sup>**(1)**</sup> 

|**BYTE**|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|---|---|---|---|---|---|---|---|---|
|1|H11|H10|H9|H8|H7|H6|H5|H4|
||(H12)|(H11)|(H10)|(H9)|(H8)|(H7)|(H6)|(H5)|
|**BYTE**|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|2|H3|H2|H1|H0|0|0|0|0|
||(H4)|(H3)|(H2)|(H1)|(H0)|(0)|(0)|(0)|



(1) Extended mode 13-bit configuration shown in parenthesis. 

**Table 11. Bytes 1 and 2 of TLOW Register**<sup>**(1)**</sup> 

|**BYTE**|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|---|---|---|---|---|---|---|---|---|
|1|L11|L10|L9|L8|L7|L6|L5|L4|
||(L12)|(L11)|(L10)|(L9)|(L8)|(L7)|(L6)|(L5)|
|**BYTE**|**D7**|**D6**|**D5**|**D4**|**D3**|**D2**|**D1**|**D0**|
|2|L3|L2|L1|L0|0|0|0|0|
||(L4)|(L3)|(L2)|(L1)|(L0)|(0)|(0)|(0)|



(1) Extended mode 13-bit configuration shown in parenthesis. 

###### **BUS OVERVIEW** 

The device that initiates the transfer is called a _master_ , and the devices controlled by the master are _slaves_ . The bus must be controlled by a master device that generates the serial clock (SCL), controls the bus access, and generates the START and STOP conditions. 

To address a specific device, a START condition is initiated, indicated by pulling the data-line (SDA) from a high to low logic level while SCL is high. All slaves on the bus shift in the slave address byte on the rising edge of the clock, with the last bit indicating whether a read or write operation is intended. During the ninth clock pulse, the slave being addressed responds to the master by generating an Acknowledge and pulling SDA low. 

Data transfer is then initiated and sent over eight clock pulses followed by an Acknowledge Bit. During data transfer SDA must remain stable while SCL is high, because any change in SDA while SCL is high will be interpreted as a START or STOP signal. 

Once all data have been transferred, the master generates a STOP condition indicated by pulling SDA from low to high, while SCL is high. 

SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... **www.ti.com** 

###### **SERIAL INTERFACE** 

The TMP102 operates as a slave device only on the two-wire bus and SMBus. Connections to the bus are made via the open-drain I/O lines SDA and SCL. The SDA and SCL pins feature integrated spike suppression filters and Schmitt triggers to minimize the effects of input spikes and bus noise. The TMP102 supports the transmission protocol for both fast (1kHz to 400kHz) and high-speed (1kHz to 3.4MHz) modes. All data bytes are transmitted MSB first. 

###### **SERIAL BUS ADDRESS** 

To communicate with the TMP102, the master must first address slave devices via a slave address byte. The slave address byte consists of seven address bits, and a direction bit indicating the intent of executing a read or write operation. 

The TMP102 features an address pin to allow up to four devices to be addressed on a single bus. Table 12 describes the pin logic levels used to properly connect up to four devices. 

**Table 12. Address Pin and Slave Addresses** 

|**DEVICE TWO-WIRE**<br>**ADDRESS**|**A0 PIN CONNECTION**|
|---|---|
|1001000|Ground|
|1001001|V+|
|1001010|SDA|
|1001011|SCL|



###### **WRITING/READING OPERATION** 

Accessing a particular register on the TMP102 is accomplished by writing the appropriate value to the Pointer Register. The value for the Pointer Register is the first byte <u>transferred</u> after the slave address byte with the R/W bit low. Every write operation to the TMP102 requires a value for the Pointer Register (see Figure 13). 

When reading from the TMP102, the last value stored in the Pointer Register by a write operation is used to determine which register is read by a read operation. To change the register pointer for a read operation, a new value must be written to the Pointer Register. 

This action is accomplished by issuing a slave address byte with the R/W bit low, followed by the Pointer Register byte. No additional data are required. The master can then generate a START condition and send the slave address byte with the R/W bit high to initiate the read command. See Figure 14 for details of this sequence. If repeated reads from the same register are desired, it is not necessary to continually send the Pointer Register bytes, because the TMP102 remembers the Pointer Register value until it is changed by the next write operation. 

Note that register bytes are sent with the most significant byte first, followed by the least significant byte. 

###### **SLAVE MODE OPERATIONS** 

The TMP102 can operate as a slave receiver or slave transmitter. As a slave device, the TMP102 never drives the SCL line. 

###### **Slave Receiver Mode:** 

The first byte transmitted by the master is the slave address, with the R/W bit low. The TMP102 then acknowledges reception of a valid address. The next byte transmitted by the master is the Pointer Register. The TMP102 then acknowledges reception of the Pointer Register byte. The next byte or bytes are written to the register addressed by the Pointer Register. The TMP102 acknowledges reception of each data byte. The master can terminate data transfer by generating a START or STOP condition. 

###### **Slave Transmitter Mode:** 

The first byte transmitted <u>by</u> the master is the slave address, with the R/W bit high. The slave acknowledges reception of a valid slave address. The next byte is transmitted by the slave and is the most significant byte of the register indicated by the Pointer Register. The master acknowledges reception of the data byte. The next byte transmitted by the slave is the least significant byte. The master acknowledges reception of the data byte. The master can terminate data transfer by generating a _Not-Acknowledge_ on reception of any data byte, or generating a START or STOP condition. 

###### **SMBus ALERT FUNCTION** 

The TMP102 supports the SMBus Alert function. When the TMP102 operates in Interrupt mode (TM = '1'), the ALERT pin may be connected as an SMBus Alert signal. When a master senses that an ALERT condition is present on the ALERT line, the master sends an SMBus Alert command (00011001) to the bus. If the ALERT pin is active, the device acknowledges the SMBus Alert command and responds by returning its slave address on the SDA line. The eighth bit (LSB) of the slave address byte indicates if the ALERT condition was caused by the temperature exceeding THIGH or falling below TLOW. For POL = '0', this bit is low if the temperature is greater than or equal to THIGH; this bit is high if the temperature is less than TLOW. The polarity of this bit is inverted if POL = '1'. Refer to Figure 15 for details of this sequence. 

If multiple devices on the bus respond to the SMBus Alert command, arbitration during the slave address portion of the SMBus Alert command determines which device will clear its ALERT status. The device with the lowest two-wire address wins the arbitration. If the TMP102 wins the arbitration, its ALERT pin becomes inactive at the completion of the SMBus Alert command. If the TMP102 loses the arbitration, its ALERT pin remains active. 

###### **GENERAL CALL** 

The TMP102 responds to a two-wire General Call address (0000000) if the eighth bit is '0'. The device acknowledges the General Call address and responds to commands in the second byte. If the second byte is 00000110, the TMP102 internal registers are reset to power-up values. The TMP102 does not support the General Address acquire command. 

###### **HIGH-SPEED (Hs) MODE** 

In order for the two-wire bus to operate at frequencies above 400kHz, the master device must issue an Hs-mode master code (00001xxx) as the first byte after a START condition to switch the bus to high-speed operation. The TMP102 does not acknowledge this byte, but switches its input filters on SDA and SCL and its output filters on SDA to operate in Hs-mode, allowing transfers at up to 3.4MHz. After the Hs-mode master code has been issued, the master transmits a two-wire slave address to initiate a data transfer operation. The bus continues to operate in Hs-mode until a STOP condition occurs on the bus. Upon receiving the STOP condition, the TMP102 switches the input and output filters back to fast-mode operation. 

###### **TIMEOUT FUNCTION** 

The TMP102 resets the serial interface if SCL is held low for 30ms (typ). The TMP102 releases the bus if it is pulled low and waits for a START condition. To avoid activating the timeout function, it is necessary to maintain a communication speed of at least 1kHz for SCL operating frequency. 

###### **NOISE** 

The TMP102 is a very low-power device and generates very low noise on the supply bus. Applying an RC filter to the V+ pin of the TMP102 can further reduce any noise the TMP102 might propagate to other components. RF in Figure 11 should be less than 5k Ω and CF should be greater than 10nF. 



<!-- Start of picture text -->
Supply�Voltage<br>TMP102 RF � 5k�<br>SCL SDA<br>GND V+<br>CF � 10nF<br>ALERT ADD0<br><!-- End of picture text -->

**Figure 11. Noise Reduction** 

SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... **www.ti.com** 

###### **TIMING DIAGRAMS** 

The TMP102 is two-wire and SMBus compatible. Figure 12 to Figure 15 describe the various operations on the TMP102. Parameters for Figure 12 are defined in Table 13. Bus definitions are: 

**Bus Idle:** Both SDA and SCL lines remain high. 

**Start Data Transfer:** A change in the state of the SDA line, from high to low, while the SCL line is high, defines a START condition. Each data transfer is initiated with a START condition. 

**Stop Data Transfer:** A change in the state of the SDA line from low to high while the SCL line is high defines a STOP condition. Each data transfer is terminated with a repeated START or STOP condition. 

**Data Transfer:** The number of data bytes transferred between a START and a STOP condition is not limited and is determined by the master device. It is also possible to use the TMP102 for single byte updates. To update only the MS byte, terminate the communication by issuing a START or STOP communication on the bus. 

**Acknowledge:** Each receiving device, when addressed, is obliged to generate an Acknowledge bit. A device that acknowledges must pull down the SDA line during the Acknowledge clock pulse in such a way that the SDA line is stable low during the high period of the Acknowledge clock pulse. Setup and hold times must be taken into account. On a master receive, the termination of the data transfer can be signaled by the master generating a _Not-Acknowledge_ ('1') on the last byte that has been transmitted by the slave. 

**Table 13. Timing Diagram Definitions** 

|||**FAST**|**MODE**|**HIGH-SPE**|**ED MODE**||
|---|---|---|---|---|---|---|
|**PARAMETER**|**TEST CONDITIONS**|**MIN**|**MAX**|**MIN**|**MAX**|**UNIT**|
|f(SCL)|SCL Operating Frequency, VS> 1.7V|0.001|0.4|0.001|3.4|MHz|
|f(SCL)|SCL Operating Frequency, VS< 1.7V|0.001|0.4|0.001|2.75|MHz|
|t(BUF)|Bus Free Time Between STOP and START<br>Condition|600||160||ns|
|t(HDSTA)|Hold time after repeated START condition.<br>After this period, the first clock is generated.|100||100||ns|
|t(SUSTA)|Repeated START Condition Setup Time|100||100||ns|
|t(SUSTO)|STOP Condition Setup Time|100||100||ns|
|t(HDDAT)|Data Hold Time|0||0||ns|
|t(SUDAT)|Data Setup Time|100||10||ns|
|t(LOW)|SCL Clock Low Period, VS> 1.7V|1300||160||ns|
|t(LOW)|SCL Clock Low Period, VS< 1.7V|1300||200||ns|
|t(HIGH)|SCL Clock High Period|600||60||ns|
|tF|Clock/Data Fall Time||300|||ns|
|tR|Clock/Data Rise Time||300||160|ns|
|tR|Clock/Data Rise Time for SCLK≤100kHz||1000|||ns|



###### **TWO-WIRE TIMING DIAGRAMS** 



<!-- Start of picture text -->
t(LOW)<br>tR tF t(HDSTA)<br>SCL<br>t(HDSTA) t(HIGH) t(SUSTA) t(SUSTO)<br>t(HDDAT) t(SUDAT)<br>SDA<br>t(BUF)<br>P S S P<br>Figure 12. Two-Wire Timing Diagram<br>1 9 1 9<br>SCL �<br>SDA 1 0 0 1 0 A1 (1) A0 (1) R/W 0 0 0 0 0 0 P1 P0 �<br>Start�By ACK�By ACK�By<br>Master TMP102 TMP102<br>Frame�1�Two-Wire�Slave�Address�Byte Frame�2�Pointer�Register�Byte<br>1 9 1 9<br>SCL<br>(Continued)<br>SDA<br>D7 D6 D5 D4 D3 D2 D1 D0 D7 D6 D5 D4 D3 D2 D1 D0<br>(Continued)<br>ACK�By ACK�By Stop�By<br>TMP102 TMP102 Master<br>Frame�3�Data�Byte�1 Frame�4�Data�Byte�2<br>NOTE:�(1)�The�value�of�A0�and�A1�are�determined�by�the�ADD0�pin.<br><!-- End of picture text -->

**Figure 13. Two-Wire Timing Diagram for Write Word Format** 

#### **TMP102** 



<!-- Start of picture text -->
SBOS397B–AUGUST 2007–REVISED OCTOBER 2008 ............................................................................................................................................... www.ti.com<br><!-- End of picture text -->



<!-- Start of picture text -->
1 9 1 9<br>SCL �<br>SDA 1 0 0 1 0 A1(1) A0(1) R/W 0 0 0 0 0 0 P1 P0<br>Start�By ACK�By ACK�By Stop�By<br>Master TMP102 TMP102 Master<br>Frame�1�Two-Wire�Slave�Address�Byte Frame�2�Pointer�Register�Byte<br>1 9 1 9<br>SCL<br>(Continued) �<br>SDA 1 0 0 1 0 A1(1) A0(1) R/W D7 D6 D5 D4 D3 D2 D1 D0 �<br>(Continued)<br>Start�By ACK�By From ACK�By<br>Master TMP102 TMP102 Master (2)<br>Frame�3�Two-Wire�Slave�Address�Byte Frame�4�Data�Byte�1�Read�Register<br>1 9<br>SCL<br>(Continued)<br>SDA<br>D7 D6 D5 D4 D3 D2 D1 D0<br>(Continued)<br>From ACK�By Stop�By<br>TMP102 Master (3) Master<br>Frame�5�Data�Byte�2�Read�Register<br>NOTE: (1)�The�value�of�A0�and�A1�are�determined�by�the�ADD0�pin.<br>(2)�Master�should�leave�SDA�high�to�terminate�a�single-byte�read�operation.<br>(3)�Master�should�leave�SDA�high�to�terminate�a�two-byte�read�operation.<br><!-- End of picture text -->

**Figure 14. Two-Wire Timing Diagram for Read Word Format** 



<!-- Start of picture text -->
ALERT<br>1 9 1 9<br>SCL<br>SDA 0 0 0 1 1 0 0 R/W 1 0 0 1 A1 A0 Status<br>Start�By ACK�By From NACK�By Stop�By<br>Master TMP102 TMP102 Master Master<br>Frame�1�SMBus�ALERT�Response�Address�Byte Frame�2�Slave�Address�From�TMP102<br>NOTE:�(1)�The�value�of�A0�and�A1�are�determined�by�the�ADD0�pin.<br><!-- End of picture text -->

**Figure 15. Timing Diagram for SMBus ALERT** 



###### **PACKAGING INFORMATION** 

|**Orderable Device**|**Status **<sup>**(1)**</sup>|**Package**<br>**Type**|**Package**<br>**Drawing**|**Pins**<br>**Packag**<br>**Qty**|**e**<br>**Eco Plan **<sup>**(2)**</sup>|**Lead/Ball Finish**|<br>**MSL Peak Temp **<sup>**(3)**</sup>|
|---|---|---|---|---|---|---|---|
|TMP102AIDRLR|ACTIVE|SOT|DRL|6<br>4000|Green (RoHS &<br>no Sb/Br)|CU NIPDAU|Level-1-260C-UNLIM|
|TMP102AIDRLRG4|ACTIVE|SOT|DRL|6<br>4000|Green (RoHS &<br>no Sb/Br)|CU NIPDAU|Level-1-260C-UNLIM|
|TMP102AIDRLT|ACTIVE|SOT|DRL|6<br>250|Green (RoHS &<br>no Sb/Br)|CU NIPDAU|Level-1-260C-UNLIM|
|TMP102AIDRLTG4|ACTIVE|SOT|DRL|6<br>250|Green (RoHS &<br>no Sb/Br)|CU NIPDAU|Level-1-260C-UNLIM|



**(1)** The marketing status values are defined as follows: 

**ACTIVE:** Product device recommended for new designs. 

**LIFEBUY:** TI has announced that the device will be discontinued, and a lifetime-buy period is in effect. 

**NRND:** Not recommended for new designs. Device is in production to support existing customers, but TI does not recommend using this part in a new design. 

**PREVIEW:** Device has been announced but is not in production. Samples may or may not be available. 

**OBSOLETE:** TI has discontinued the production of the device. 

> **(2)** Eco Plan - The planned eco-friendly classification: Pb-Free (RoHS), Pb-Free (RoHS Exempt), or Green (RoHS & no Sb/Br) - please check http://www.ti.com/productcontent for the latest availability information and additional product content details. **TBD:** The Pb-Free/Green conversion plan has not been defined. 

**Pb-Free (RoHS):** TI's terms "Lead-Free" or "Pb-Free" mean semiconductor products that are compatible with the current RoHS requirements for all 6 substances, including the requirement that lead not exceed 0.1% by weight in homogeneous materials. Where designed to be soldered at high temperatures, TI Pb-Free products are suitable for use in specified lead-free processes. 

**Pb-Free (RoHS Exempt):** This component has a RoHS exemption for either 1) lead-based flip-chip solder bumps used between the die and package, or 2) lead-based die adhesive used between the die and leadframe. The component is otherwise considered Pb-Free (RoHS compatible) as defined above. 

**Green (RoHS & no Sb/Br):** TI defines "Green" to mean Pb-Free (RoHS compatible), and free of Bromine (Br) and Antimony (Sb) based flame retardants (Br or Sb do not exceed 0.1% by weight in homogeneous material) 

> **(3)** MSL, Peak Temp. -- The Moisture Sensitivity Level rating according to the JEDEC industry standard classifications, and peak solder temperature. 

**Important Information and Disclaimer:** The information provided on this page represents TI's knowledge and belief as of the date that it is provided. TI bases its knowledge and belief on information provided by third parties, and makes no representation or warranty as to the accuracy of such information. Efforts are underway to better integrate information from third parties. TI has taken and continues to take reasonable steps to provide representative and accurate information but may not have conducted destructive testing or chemical analysis on incoming materials and chemicals. TI and TI suppliers consider certain information to be proprietary, and thus CAS numbers and other limited information may not be available for release. 

In no event shall TI's liability arising out of such information exceed the total purchase price of the TI part(s) at issue in this document sold by TI to Customer on an annual basis. 



<!-- Start of picture text -->
48 Texas<br>INSTRUMENTS<br><!-- End of picture text -->

### **PACKAGE MATERIALS INFORMATION** 

22-Oct-2008 

###### **TAPE AND REEL INFORMATION** 



<!-- Start of picture text -->
REEL DIMENSIONS TAPE DIMENSIONS<br>Se SOS SSS ft<br>\_/ i KO Pt<br>Reel — — — |<br>Diameter Cavity AO<br>Dimension designed to accommodate the component width<br>[Bo[ Dimension designed to accommodate the component length<br>Dimension designed to accommodate the component thickness|<br>Overall width of the carrier tape<br>+ Pitch between successive cavity centers<br>t Reel Width (W1)<br>QUADRANT ASSIGNMENTS FOR PIN 1 ORIENTATION IN TAPE<br>MO 0000000 0 0 Sprocket Holes<br>[ a1! ae | [ ar | a | gpraseaanny<br>--4--4. 1 =><br>| Q3 1I Q4 featQ3 |1 Q4 | Ww\ User Direction of Feed<br>NI”<br>Pocket Quadrants<br><!-- End of picture text -->

*All dimensions are nominal 

|**Device**|**Package**<br>**Type**|**Package**<br>**Drawing**<br>|**Pins**|**SPQ**|**Reel**<br>**Diameter**<br>**(mm)**|**Reel**<br>**Width**<br>**W1(mm)**|**A0 (mm)**|**B0 (mm)**|**K0 (mm)**|**P1**<br>**(mm)**|**W**<br>**(mm)**|**Pin1**<br>**Quadrant**|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
|TMP102AIDRLR|SOT|DRL|6|4000|180.0|9.2|1.78|1.78|0.69|4.0|8.0|Q3|
|TMP102AIDRLT|SOT|DRL|6|250|180.0|9.2|1.78|1.78|0.69|4.0|8.0|Q3|





<!-- Start of picture text -->
we TEXAS<br>INSTRUMENTS<br><!-- End of picture text -->

22-Oct-2008 



<!-- Start of picture text -->
TAPE AND REEL BOX DIMENSIONS<br>/<br>/<br>y<br>‘) oy<br>Oe<br>Z ae SX<br>Le 7a<br>>a—<br><!-- End of picture text -->

*All dimensions are nominal 

|**Device**|**Package Type**|**Package Drawing**|**Pins**|**SPQ**|**Length (mm)**|**Width (mm)**|**Height (mm)**|
|---|---|---|---|---|---|---|---|
|TMP102AIDRLR|SOT|DRL|6|4000|202.0|201.0|28.0|
|TMP102AIDRLT|SOT|DRL|6|250|202.0|201.0|28.0|



## PL ~~AS~~ <u>TIC</u> SM ~~A~~ LL OUTLIN ~~E~~ 



<!-- Start of picture text -->
af 1,70<br>1,50<br>A oy 021 0,13<br>EI 6 5 4<br>Ti ii} ‘|<br>|<br>2<br>& 1,30 | | _ | 1,70<br>1,10 i . 1,50<br>I NNE<br>Ld 2 st<br>Pin 1 Index Area , I<br>0,50 8x Oa<br>[555 }-4+ —4 ts<br>© 0,05 040 CATS]  ®<br>0,60<br>0,50<br>0,05 — na Seating Plane 0.18<br>0,00 0,08<br>oe<br>0,40<br>-<br>~—— +<br>LGU<br>Bottom View 420562 2- 3/D 08/2007<br>NOT ES : A. Al l linear dimensions are in millimeters. Dimensioning and tolerancing per A SM E Y14.5M -1 994.<br>B. This drawing is subject to change without notice.<br>A\ Body dimensions do no t include mold f lash, i nt erlead f lash, pro tr usions, or ga t e burrs<br>Mold flash, interlead flash, protrusions, or gate burrs shall not exceed 0,15 per end or side.<br>D. JE D E C package registration is pending<br><!-- End of picture text -->

###### **IMPORTANT NOTICE** 

Texas Instruments Incorporated and its subsidiaries (TI) reserve the right to make corrections, modifications, enhancements, improvements, and other changes to its products and services at any time and to discontinue any product or service without notice. Customers should obtain the latest relevant information before placing orders and should verify that such information is current and complete. All products are sold subject to TI’s terms and conditions of sale supplied at the time of order acknowledgment. 

TI warrants performance of its hardware products to the specifications applicable at the time of sale in accordance with TI’s standard warranty. Testing and other quality control techniques are used to the extent TI deems necessary to support this warranty. Except where mandated by <u>government</u> requirements, testing of all parameters of each product is not necessarily <u>performed.</u> 

TI assumes no liability for applications assistance or customer product design. Customers are responsible for their products and applications using TI components. To minimize the risks associated with customer products and applications, customers should provide adequate design and operating safeguards. 

TI does not warrant or represent that any license, either express or implied, is granted under any TI patent right, copyright, mask work right, or other TI intellectual property right relating to any combination, machine, or process in which TI products or services are used. Information published by TI regarding third-party products or services does not constitute a license from TI to use such products or services or a warranty or endorsement thereof. Use of such information may require a license from a third party under the patents or other intellectual <u>property</u> of the third <u>party, or</u> a license from TI under the patents or other intellectual <u>property of</u> TI. 

Reproduction of TI information in TI data books or data sheets is permissible only if reproduction is without alteration and is accompanied by all associated warranties, conditions, limitations, and notices. Reproduction of this information with alteration is an unfair and deceptive business practice. TI is not responsible or liable for such altered documentation. Information of third parties may be subject to additional restrictions. 

Resale of TI products or services with statements different from or beyond the parameters stated by TI for that product or service voids all express and any implied warranties for the associated TI product or service and is an unfair and deceptive business practice. TI is not responsible or liable for any such statements. 

TI products are not authorized for use in safety-critical applications (such as life support) where a failure of the TI product would reasonably be expected to cause severe personal injury or death, unless officers of the parties have executed an agreement specifically governing such use. Buyers represent that they have all necessary expertise in the safety and regulatory ramifications of their applications, and acknowledge and agree that they are solely responsible for all legal, regulatory and safety-related requirements concerning their products and any use of TI products in such safety-critical applications, notwithstanding any applications-related information or support that may be provided by TI. Further, Buyers must fully indemnify TI and its representatives against any damages arising out of the use of TI products in such safety-critical applications. 

TI products are neither designed nor intended for use in military/aerospace applications or environments unless the TI products are specifically designated by TI as military-grade or "enhanced plastic." Only products designated by TI as military-grade meet military specifications. Buyers acknowledge and agree that any such use of TI products which TI has not designated as military-grade is solely at the Buyer's risk, and that they are solely responsible for compliance with all legal and regulatory requirements in connection with such use. 

TI products are neither designed nor intended for use in automotive applications or environments unless the specific TI products are designated by TI as compliant with ISO/TS 16949 requirements. Buyers acknowledge and agree that, if they use any non-designated <u>products</u> in automotive applications, TI will not be responsible for any failure to meet such requirements. 

Following are URLs where you can obtain information on other Texas Instruments <u>products and</u> application solutions: 

|**Products**<br>Amplifiers|amplifier.ti.com|**Applications**<br>Audio|www.ti.com/audio|
|---|---|---|---|
|Data Converters|dataconverter.ti.com|Automotive|www.ti.com/automotive|
|DSP|dsp.ti.com|Broadband|www.ti.com/broadband|
|Clocks and Timers<br>Interface|www.ti.com/clocks<br>interface.ti.com|Digital Control<br>Medical|www.ti.com/digitalcontrol<br>www.ti.com/medical|
|Logic|logic.ti.com|Military|www.ti.com/military|
|Power Mgmt|power.ti.com|Optical Networking|www.ti.com/opticalnetwork|
|Microcontrollers|microcontroller.ti.com|Security|www.ti.com/security|
|RFID|www.ti-rfid.com|Telephony|www.ti.com/telephony|
|RF/IF and ZigBee® Solutions|www.ti.com/lprf|Video & Imaging<br>Wireless|www.ti.com/video<br>www.ti.com/wireless|



Mailing Address: Texas Instruments, Post Office Box 655303, Dallas, Texas 75265 

Copyright © 2008, Texas Instruments Incorporated 

