

<!-- Start of picture text -->
SENSIRION<br><!-- End of picture text -->

# **SCD4x** 

## Breaking the size barrier in optical CO2 sensing 



<!-- Start of picture text -->
>.<br><!-- End of picture text -->



<!-- Start of picture text -->
><br><!-- End of picture text -->

#### **Features** 

#### **Product Variants** 

- Photoacoustic NDIR sensor technology PASens® 

   - **SCD40** : Base accuracy, specified measurement range 400 – 2’000 ppm, compatible with WELL Building Standard™<sup>1</sup> 

- Small form factor: 10.1 x 10.1 x 6.5 mm<sup>3</sup> 

- Reflow solderable for cost-effective assembly 

   - **SCD41** : Improved accuracy, specified measurement range 400 – 5’000 ppm, additionally compatible with California Title 24<sup>2</sup> and RESET<sup>®3</sup> , features single-shot operation mode 

- Digital I<sup>2</sup> C interface 

- Integrated temperature and humidity sensor 

- **SCD43** : High accuracy, specified measurement range 400 – 5’000 ppm, additionally compatible with ASHRAE Standard 62.1<sup>4</sup> , features single-shot operation mode 

#### **Product Summary** 

The SCD4x is Sensirion’s second generation series of optical CO2 sensors. The sensor series builds on the photoacoustic NDIR sensing principle and Sensirion’s patented PASens® and CMOSens® technology to offer high accuracy at an attractive price and small form factor. SMD assembly allows cost- and space-effective integration of the sensor combined with maximal freedom of design. On-chip signal compensation is realized with the built-in SHT4x humidity and temperature sensor. 

CO2 is a key indicator for indoor air quality (IAQ), as high levels compromise human cognitive performance, sleep quality, well-being and can be an indicator for increased airborne disease transmission risk. The SCD4x enables smart ventilation and air conditioning to help improve energy efficiency and human comfort. Moreover, indoor air quality monitors and other connected devices based on the SCD4x can help maintain low CO2 concentrations for a healthy, productive environment. 

#### **Product Overview** 

|Products|Details|
|---|---|
|SCD40-D-R2|Base accuracy, specified range<br>400 – 2’000ppm|
|SCD41-D-R2|Improved accuracy, specified range<br>400 – 5’000 ppm, single shot operation<br>feature|
|SCD43-D-R2|High accuracy, specified range<br>400 – 5’000 ppm, comprehensive building<br>standard compatibility, single shot<br>operation feature|



#### **Functional Block Diagram** 



1 2 3 4 

> 1 WELL v2, Q4 2024 

> 2 2022 California Building Energy Efficiency Standards for Residential and Nonresidential Buildings 

> 3 RESET Air Standard v2.0 Grade B 

> 4 ASHRAE 62.1-2022 incl. Addendum d 



### **Table of Contents** 

|**1**<br>**Se**|**nsor Performance**......................................................................................................................................... 3|
|---|---|
|1.1|CO2Sensing Performance .......................................................................................................................... 3|
|1.2|Humidity Sensing Performance ................................................................................................................... 3|
|1.3|Temperature Sensing Performance ............................................................................................................. 3|
|**2**<br>**Sp**|**ecifications**.................................................................................................................................................... 4|
|2.1|Electrical Specifications ............................................................................................................................... 4|
|2.2|Absolute Maximum Ratings ......................................................................................................................... 4|
|2.3|Interface Specifications ............................................................................................................................... 5|
|2.4|Timing Specifications................................................................................................................................... 6|
|2.5|Material Contents ........................................................................................................................................ 6|
|**3**<br>**Dig**|**ital Interface Description**............................................................................................................................. 7|
|3.1|Power-Up and Communication Start ........................................................................................................... 7|
|3.2|Sensor I<sup>2</sup>C Address ..................................................................................................................................... 7|
|3.3|Data Type & Length .................................................................................................................................... 7|
|3.4|Command Sequence Types ........................................................................................................................ 7|
|3.5|SCD4x Command Overview ........................................................................................................................ 8|
|3.6|Basic Commands ........................................................................................................................................ 9|
|3.7|On-Chip Output Signal Compensation ...................................................................................................... 10|
|3.8|Field Calibration ........................................................................................................................................ 13|
|3.9|Low Power Periodic Measurement Mode .................................................................................................. 15|
|3.10|Advanced Features ................................................................................................................................... 16|
|3.11|Single Shot Measurement Mode (SCD41 & SCD43 only) ......................................................................... 19|
|3.12|Checksum Calculation ............................................................................................................................... 23|
|**4**<br>**Me**|**chanical Specifications**.............................................................................................................................. 24|
|4.1|Package Outline ........................................................................................................................................ 24|
|4.2|Land Pattern Recommendation ................................................................................................................. 24|
|4.3|Tape & Reel Package................................................................................................................................ 25|
|4.4|Moisture Sensitivity Level .......................................................................................................................... 25|
|4.5|Soldering Instructions ................................................................................................................................ 26|
|4.6|<br>Traceability and Identification .................................................................................................................... 26|
|**5**<br>**Or**|**dering Information**....................................................................................................................................... 27|
|5.1|Historical Information ................................................................................................................................. 27|
|**6**<br>**Re**|**vision History**.............................................................................................................................................. 28|





### **1 Sensor Performance** 

#### **1.1 CO2 Sensing Performance** 

Default conditions of 25 °C, 50 %RH, ambient pressure of 1013 mbar, continuous operation in periodic measurement mode (see Section 3.6.1) and 3.3 V supply voltage apply to values in the table below, unless otherwise stated. 

|Parameter|Conditions|Value|
|---|---|---|
|CO2output range<sup>5</sup>|-|0 – 40’000ppm|
|SCD40 CO2measurement accuracy<sup>6</sup>|400ppm – 2’000ppm|±(50ppm + 5% of reading)|
||400ppm – 1’000ppm|±(50ppm + 2.5% of reading)|
|SCD41 CO2measurement accuracy<sup>6</sup>|1’001ppm – 2’000ppm|±(50ppm + 3% of reading)|
||2’001ppm – 5’000ppm|±(40ppm + 5% of reading)|
|SCD43 CO2measurement accuracy<sup>6</sup>|400ppm – 5’000ppm|±(30ppm + 3% of reading)|
|Repeatability|Typical|±10ppm|
|Response time<sup>7</sup>|τ63%,typical,stepchange 400 – 2’000ppm|60 s|
|Additional accuracy drift per year, starting<br>after fiveyears<sup>8</sup>|Typical, same CO2concentration range as<br>sensor’s specified measurement accuracy|±(5 ppm + 0.5 % of reading)|



**Table 1** : SCD4x CO2 sensor specifications 

#### **1.2 Humidity Sensing Performance** 

SCD4x design-in, self-heating, operation mode and the surrounding environment affects RH/T sensor performance. To achieve the specifications in **Table 2** , the temperature-offset of the SCD4x inside the customer device must be set correctly (see Section 3.7). 

|Parameter|Conditions|Value|
|---|---|---|
|Humiditymeasurement range|-|0 %RH – 100 %RH|
|A t|15 °C – 35 °C,20 %RH – 65 %RH|±6 %RH|
|ccuracy (yp.)|-10 °C – 60 °C,0 %RH – 100 %RH|±9 %RH|
|Repeatability|Typical|±0.4 %RH|
|Response time<sup>7</sup>|τ63%,typical, periodic measurement mode|90 s|
|Accuracydrift|-|<0.25 %RH /year|



**Table 2** : SCD4x humidity sensor specifications 

#### **1.3 Temperature Sensing Performance** 

SCD4x design-in, self-heating, operation mode and the surrounding environment affects RH/T sensor performance. To achieve the specifications in **Table 3** , the temperature-offset of the SCD4x inside the customer device must be set correctly (see Section 3.7) 

|Parameter|Conditions|Value|
|---|---|---|
|Temperature measurement range|-|- 10 °C – 60 °C|
|Accrac (t)|15 °C – 35 °C|± 0.8 °C|
|uy yp.|-10 °C – 60 °C|± 1.5 °C|
|Repeatability|-|± 0.1 °C|
|Response time<sup>7</sup>|τ63%,typical, periodic measurement mode|120 s|
|Accuracydrift|-|< 0.03 °C /year|



**Table 3** : SCD4x temperature sensor specifications 

> 5 Exposure to CO2 concentrations smaller than 400 ppm can affect the accuracy of the sensor with ASC enabled. 

> 6 Deviation from a high-precision reference with gas mixtures having a ±2% tolerance. Rough handling, shipping, sensor assembly and long-term drift can impact sensor accuracy. Accuracy can be restored by performing forced recalibration (FRC) no less than 5 days after sensor assembly, or maintained by sensor operation with automatic self-calibration (ASC) enabled using default parameters and weekly exposure to air with CO2 concentrations at 400 ppm. See Section 3.8 for details. 7 Response time depends on design-in, signal update rate and environment of the sensor in the final application. 

> 8 Deviation is additional to standard accuracy specifications and obtained either after performing FRC or in continuous sensor operation with ASC enabled using default parameters and weekly exposure to air with CO2 concentrations at 400 ppm. Maximum additional accuracy drift per year starting after five years estimated from stress tests is ±(5 ppm + 2% of reading). Stronger drift may occur if the sensor is not handled according to its handling instructions. 



### **2 Specifications** 

#### **2.1 Electrical Specifications** 

|Parameter|Symbol|Conditions|Min.|Typical|Max.|Units|
|---|---|---|---|---|---|---|
|Supplyvoltage DC<sup>9</sup>|VDD||2.4|3.3 or 5.0|5.5|V|
|Unloaded supplyvoltage ripple(peak topeak)<sup>10</sup>|VRPP||||30|mV|
|Pk l t<sup>11</sup>|I|VDD= 3.3 V||175|205|mA|
|ea suppy curren|peak|VDD= 5 V||115|137|mA|
|Average supply current for periodic measurement|I|VDD= 3.3 V||15|18|mA|
|mode (1 measurement every 5 seconds)|DD|VDD= 5 V||11|13|mA|
|Average supply current for low power periodic||VDD= 3.3 V||3.2|3.5|mA|
|measurement mode (1 measurement every 30<br>seconds)|IDD|VDD= 5 V||2.8|3|mA|
|Average supply current for single shot mode, 1|I|VDD= 3.3 V||0.45|0.5|mA|
|measurement every 5 minutes (SCD41/SCD43)<sup>12</sup>|DD|VDD= 5 V||0.36|0.4|mA|
|Input high level voltage|VIH||0.65 x VDD||1 x VDD|-|
|Input low level voltage|VIL||||0.3 x VDD|-|
|Output low level voltage|VOL|3 mA sink current|||0.66|V|



**Table 4** : SCD4x electrical specifications 

#### **2.2 Absolute Maximum Ratings** 

Stress levels beyond those listed in **Table 5** may cause permanent damage to the device. Exposure to minimum/maximum rating conditions for extended periods may affect sensor performance and device reliability. 

|Parameter|Conditions|Value|
|---|---|---|
|Temperature operatingconditions||-10 – 60 °C|
|Humidityoperatingconditions<sup>13</sup>|Non-condensing|0 – 95 %RH|
|MSL Level||1|
|DC supplyvoltage||-0.3 V – 6.0 V|
|Max. voltage onpins SDA,SCL,GND||-0.3 V – VDD+ 0.3 V|
|Input current onpins SDA,SCL,GND||-280 mA – 100 mA|
|Short term storage temperature<sup>14</sup>||-40 °C – 70 °C|
|Recommended storage temperature||10 °C – 50 °C|
|ESD HBM(pads and metal cap)||2 kV|
|ESD CDM||500 V|
|Maintenance interval|Maintenance free when the ASC<br>algorithm<sup>15</sup>is used.|None|
|Sensor lifetime<sup>16</sup>|Typical operatingconditions|>10years|



**Table 5** : SCD4x operation conditions, lifetime and maximum ratings 

> 9 Supply voltage must be kept constant for stable sensor operation. 

> 10 Determined on the supply voltage without the load of the sensor. 

> 11 Refers to sustained current. 

> 12 On-demand measurement with adjustable interval. See Section 3.11 for details. 

> 13 Accuracy can be reduced at relative humidity levels lower than 10%. 

> 14 Short term storage refers to temporary conditions e.g., during transport. 

> 15 For proper function of the ASC field-calibration algorithm with default parameters, SCD4x must be exposed to air with CO2 concentrations at 400 ppm on a weekly basis. 

> 16 Sensor tested over simulated lifetime of >10 years for an indoor environment mission profile. 



<!-- Start of picture text -->
SENSIRION<br><!-- End of picture text -->

#### **2.3 Interface Specifications** 

The SCD4x comes in an LGA package ( **Table 6** ). Further details on the sensor’s package can be found in Section 4.1. A recommended land pattern for SCD4x can be found in Section 4.2. 

|**Name**<br>~~ee~~|**Comments**|
|---|---|
|VDD<br><br>|Supply voltage<br>|
|VDDH<br><br>|Supply voltage IR source, must<br>be connected to VDD on<br>customer PCB<br>~~||~~<br>|
|GND<br><br>|Ground contact<br><br>|
|SDA<br><br>|I<sup>2</sup>C serial data, bidirectional<br><br>|
|SCL<br>~~|~~<br>|I<sup>2</sup>C serial clock<br>~~|~~<br>|
|DNC<br> <br>~~P~~|Do not connect, pads must be<br>soldered to a floating pad on<br>the customer PCB<br><br>~~lo~~|





<!-- Start of picture text -->
7:<br>me Ta iy<br>DNC 21 2<br>al I<br>ee oe<br>+ Sle (ae][ze]ae<br>BIGIGIEIEqaguict<br>ZagoGg<br>roto<br>os own<br><!-- End of picture text -->

**Table 6** : Pin assignment (top view). The notched corner of the protection membrane serves as a polarity mark to indicate pin 1 location. 

VDD and VDDH are used to supply the sensor and must always be kept at the same voltage, i.e. both should be connected to the same power supply. The combined maximum current drawn on VDD and VDDH is indicated in **Table 4** . VDD and VDDH must be connected to each other close to the sensor on the customer PCB. 

For sensor operation, a low noise power supply, such as a low-dropout regulator (LDO), which can handle the peak supply current as specified in **Table 4** must be chosen. Due to the sensor’s internal regulation, higher transient currents (on the timescale of microseconds) may be observed. These transient currents can be neglected in typical design-in scenarios due to the parasitic R/L/C of the leads as well as the load regulation characteristics of the supply. Additionally, to avoid interference with the sensor regulation, the supply voltage without the load of the sensor must not vary by more than 30 mV (e.g. ripples or drops caused by other loads). Operating the sensor with a separate LDO is recommended. 

SCD4x uses I<sup>2</sup> C communication based on NXP’s I<sup>2</sup> C-bus specification and user manual<sup>17</sup> . I<sup>2</sup> C standard and fast mode operation are supported. SCL is used to synchronize the I<sup>2</sup> C communication between the master (microcontroller) and the slave (sensor). The SDA pin is used to transfer data to and from the sensor. For safe communication, the timing specifications defined in the I<sup>2</sup> C manual<sup>17</sup> and Section 2.4 must be met. Both SCL and SDA lines should be connected to external pull-up resistors (e.g. Rp = 10 kΩ, see **Figure 1** ). To avoid signal contention, the microcontroller must only drive SDA and SCL low. For dimensioning resistor sizes, please take bus capacity and communication frequency into account (see example in Section 7.1 of NXPs I<sup>2</sup> C Manual for more details<sup>17</sup> ). Note that pull-up resistors may be included in the I/O circuits of microcontrollers. 



<!-- Start of picture text -->
VODscl Rp 1 “l SCLVDD VDDH<br>SDA SDA<br>GND<br><!-- End of picture text -->

**Figure 1:** Typical application circuit (representative and not to scale). 

> 17 NXP I2C-bus specification and user manual UM10204, Rev.6, 4 April 2014 



<!-- Start of picture text -->
SENSIRION<br><!-- End of picture text -->

#### **2.4 Timing Specifications** 

**Table 7** lists the timings of the SCD4x<sup>18</sup> . 

|**Parameter**|**Condition**|**Min.**|**Max.**|**Unit**|
|---|---|---|---|---|
|Power-up time|After hard reset,VDD≥ 2.25 V|-|30|ms|
|Soft reset time|After re-initialization(i.e. reinit)|-|30|ms|
|SCL clock frequency|-|0|400|kHz|



**Table 7** : System timing specifications. 

#### **2.5 Material Contents** 

The device is fully REACH and RoHS compliant. 

> 18 Timing specifications based on the NXP I2C-bus specification and user manual UM10204, Rev.6, 4 April 2014 



### **3 Digital Interface Description** 

#### **3.1 Power-Up and Communication Start** 

The sensor starts powering-up after reaching the power-up threshold voltage VDD,min and will take up to the maximum of the power-up time to enter the idle state. Once the idle state has been reached, it is ready to receive commands from the master. Each transmission sequence begins with a START condition (S) and ends with a STOP condition (P) as described in the I<sup>2</sup> C- bus specification. 

#### **3.2 Sensor I**<sup>**2**</sup> **C Address** 

SCD4x can be addressed by sending its 7-bit I<sup>2</sup> C address, given in **Table 8** , followed by an eighth bit denoting the communication direction: a “zero” indicates a “write” request, a “one” a “read” request. 

|**SCD4x**|**Hex. Code**|
|---|---|
|I<sup>2</sup>C address|0x62|



**Table 8** : I<sup>2</sup> C device address 

#### **3.3 Data Type & Length** 

Data sent to and received from the sensor consists of a sequence of 16-bit commands and/or 16-bit words (each to be interpreted as unsigned integer with the most significant byte transmitted first). Each data word is immediately succeeded by an 8-bit CRC. In write direction it is mandatory to transmit the checksum. In read direction it is up to the master to decide if it wants to process the checksum (see Section 3.12). 

#### **3.4 Command Sequence Types** 

The SCD4x features four different I<sup>2</sup> C command sequence types: “ _read I_<sup>_2_</sup> _C sequences”_ , “ _write I_<sup>_2_</sup> _C sequences”_ , “ _send I_<sup>_2_</sup> _C command”_ and _“send command and fetch result”_ sequences. **Figure 2** illustrates how the I<sup>2</sup> C communication for the different sequence types is built-up. 



<!-- Start of picture text -->
{00| fromfrom masterslave toto master slave —LissseresonnnwuunwirzziseresData MSB 8 Data LSB 8 CRC—BP write PC sequence<br>16-bit write data checksum<br>iit t sere erastseregenowsus send °C command<br>s| (20 Address wl Address MSB 8 Address LSB — Pl sequence<br>12C wite header ‘16-bit memory address or command<br>Less se reeressseretonenuwunms<br>Tr 234 seres<br>i x x Fs<br>° “ 7 °<br>12C read header 16-bit read data checksum<br>Lasse ereswnenueururzas<br>sores<br>Data MSB 8 Data LSB 8 orc fs)<br>er16-bit write data checksum = send command<br>and fetch result<br>Less serestzatserecwneeusenere2ssseres<br>; ress, RG S 5 g<br>12C read header 16-bit read data checksum<br><!-- End of picture text -->

**Figure 2:** Command sequence types: _“write”_ , _“send_ command”, _“read”_ , and _“send command and fetch result”_ 

For the _“read”_ or _“send command and fetch results”_ sequences, after writing the address and/or data to the sensor and receiving the ACK bit from the sensor, it is required to wait for the command _execution time_ (see **Table 9** ) before issuing the read header. If a command execution time is specified in **Table 9** , further commands must not be sent during that command’s _execution time_ . 



#### **3.5 SCD4x Command Overview** 

An overview of the available SCD4x commands can be found in **Table 9.** A detailed description for each command can be found in the following sections. Note that some commands may also be executed while a periodic measurement mode is running. 

|**Domain**|**Command**|**Hex.**<br>|**I**<sup>**2**</sup>**C sequence type**<br>|**Executio**|**n**|
|---|---|---|---|---|---|
|||**Code**|**(see Section 3.4)**|**time**<br>**[ms]**|**During**<br>**meas.**|
|Bi d|start_periodic_measurement|0x21b1|send command|-|no|
|asc commans<br>Section 36|read_measurement|0xec05|read|1|yes|
|.|stop_periodic_measurement|0x3f86|send command|500|yes|
||set_temperature_offset|0x241d|write|1|no|
||get_temperature_offset|0x2318|read|1|no|
|On-chip output signal<br>comensation|set_sensor_altitude|0x2427|write|1|no|
|p<br>Section 3.7|get_sensor_altitude|0x2322|read|1|no|
||set_ambient_pressure|0xe000|write|1|yes|
||get_ambient_pressure|0xe000|read|1|yes|
||perform_forced_recalibration|0x362f|send command and<br>fetch result|400|no|
|Field calibration|set_automatic_self_calibration_enabled|0x2416|write|1|no|
|Section 3.8|get_automatic_self_calibration_enabled|0x2313|read|1|no|
||set_automatic_self_calibration_target|0x243a|write|1|no|
||get_automatic_self_calibration_target|0x233f|read|1|no|
|Low power periodic|start_low_power_periodic_measurement|0x21ac|send command|-|no|
|measurement mode<br>Section 3.9|get_data_ready_status|0xe4b8|read|1|yes|
||persist_settings|0x3615|send command|800|no|
||get_serial_number|0x3682|read|1|no|
|Add ft|perform_self_test|0x3639|read|10’000|no|
|vance eaures<br>Section 3.10|perform_factory_reset|0x3632|send command|1’200|no|
||reinit|0x3646|send command|30|no|
||get_sensor_variant|0x202f|read|1|no|
||measure_single_shot|0x219d|send command|5’000|no|
||measure_single_shot_rht_only|0x2196|send command|50|no|
|Single shot|power_down|0x36e0|send command|1|no|
|<br>measurement mode|wake_up|0x36f6|send command|30|no|
|(SCD41 & SCD43)<br>|set_automatic_self_calibration_initial_period|0x2445|write|1|no|
|Section 3.11|get_automatic_self_calibration_initial_period|0x2340|read|1|no|
||set_automatic_self_calibration_standard_period|0x244e|write|1|no|
||get_automatic_self_calibration_standard_period|0x234b|read|1|no|



**Table 9** : List of SCD4x sensor commands. The rightmost column (‘During meas.’) indicates whether the command can be executed while a periodic measurement mode is running. 



#### **3.6 Basic Commands** 

This section lists the basic SCD4x commands that are necessary to start the periodic measurement mode and subsequently read out the sensor outputs. 

The typical communication sequence between the I<sup>2</sup> C master (e.g., a microcontroller) and the SCD4x sensor is as follows: 

1. The sensor is powered up into the idle state. 

2. The I<sup>2</sup> C master sends a _start_periodic_measurement_ command. The signal update interval is 5 seconds. 

3. The I<sup>2</sup> C master periodically reads out data with the _read_measurement_ command. 

4. When the sensor is to stop taking measurements periodically, the I<sup>2</sup> C master sends the _stop_periodic_measurement_ command to return the sensor to idle mode. 

While the periodic measurement mode is running, no other commands may be issued, with exception of _read_measurement_ , _get_data_ready_status, stop_periodic_measurement, set_ambient_pressure_ and _get_ambient_pressure._ 

#### **3.6.1 start_periodic_measurement** 

**Description** : starts the periodic measurement mode. The signal update interval is 5 seconds. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x21b1|-|-|-|-|not applicable|



**Example:** start periodic measurement 

|Write|0x21b1|
|---|---|
|_(hexadecimal)_|_Command_|



**Table 10** : start_periodic_measurement I2C sequence description 

#### **3.6.2 read_measurement** 

**Description** : reads the sensor output. The measurement data can only be read out once per signal update interval as the buffer is emptied upon read-out. If no data is available in the buffer, the sensor returns a NACK. To avoid a NACK response, the _get_data_ready_status_ can be issued to check data status (see Section 3.9.2 for further details). The I<sup>2</sup> C master can abort the read transfer with a NACK followed by a STOP condition after any data byte if the user is not interested in subsequent data. 

|**Write**<br>(hexadecimal)|**Input parameter:**-<br>length  [bytes]|signal conversion|**Response par**<br>Relative Humid<br>length  [bytes]|**ameter:**CO2, Temperature,<br>ity<br>signal conversion|Max.<br>command<br>duration [ms]|
|---|---|---|---|---|---|
||||3|𝐶𝑂2[ppm] = 𝑤𝑜𝑟𝑑[0]||
|0xec05|-|-|3|𝑇= −45 + 175 ∗<sup>𝑤𝑜𝑟𝑑[1]</sup><br>2<sup>16 </sup>−1|1|
||||3|𝑅𝐻= 100 ∗<sup>𝑤𝑜𝑟𝑑[2]</sup><br>2<sup>16 </sup>−1||



**Example:** read sensor output (500 ppm, 25 °C, 37 %RH) 

|Write|0xec05||||||
|---|---|---|---|---|---|---|
|_(hexadecimal)_|_Command_||||||
|Wait|1 ms|_command ex_|_ecution time_||||
|Response|0x01f4|0x33|0x6667|0xa2|0x5eb9|0x3c|
|_(hexadecimal)_|_CO2 = 500 ppm_|_CRC of 0x01f4_|_Temp. = 25 °C_|_CRC of 0x6667_|_RH = 37%_|_CRC of 0x5eb9_|



**Table 11** : read_measurement I<sup>2</sup> C sequence description 



#### **3.6.3 stop_periodic_measurement** 

**Description** : Command returns a sensor running in periodic measurement mode or low power periodic measurement mode back to the idle state, e.g. to then allow changing the sensor configuration or to save power. Note that the sensor will only respond to other commands 500 ms after the _stop_periodic_measurement_ command has been issued. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x3f86|-|-|-|-|500|
|**Example:**stop p|eriodic measurement|||||
|Write|0x3f86|||||
|_(hexadecimal)_|_Command_|||||



**Table 12** : stop_periodic_measurement I<sup>2</sup> C sequence description 

#### **3.7 On-Chip Output Signal Compensation** 

The SCD4x features on-chip signal compensation to automatically counteract temperature and humidity effects on CO2 measurements. Additionally, it is possible to provide the sensor with externally obtained pressure or altitude values to enable on-board compensation of the CO2 output signal for pressure variations. Furthermore, it is possible to improve the accuracy of the relative humidity and temperature output signal by adjusting the temperature offset parameter for the design-in of the sensor. Note that the temperature offset does not impact the accuracy of the CO2 output. 

To change or read sensor settings, the SCD4x must be in the idle state (exception: ambient pressure parameters). A typical sequence between the I<sup>2</sup> C master and the SCD4x is described as follows: 

1. If the sensor is operated in a periodic measurement mode, the I<sup>2</sup> C master sends a _stop_periodic_measurement_ command. 

2. The I<sup>2</sup> C master sends one or several commands to get or set sensor settings / parameters. 

3. If changes shall be retained across power-cycles, the _persist_settings_ command must be sent (see Section 3.10.1) 

4. The I<sup>2</sup> C master sends a _start_periodic_measurement_ command to set the sensor in the operating mode again. 

#### **3.7.1 set_temperature_offset** 

**Description** : Setting the temperature offset of the SCD4x inside the customer device allows the user to optimize the RH and T output signal. The temperature offset can depend on several factors such as the SCD4x measurement mode, self-heating of close components, the ambient temperature and air flow. Thus, the SCD4x temperature offset should be determined after integration into the final device and under its typical operating conditions (including the operation mode to be used in the application) in thermal equilibrium. By default, the temperature offset is set to 4 °C. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command may be issued. Equation (1) details how the characteristic temperature offset can be calculated using the current temperature output of the sensor ( 𝑇𝑆𝐶𝐷4𝑥 ), a reference temperature value ( 𝑇𝑅𝑒𝑓𝑒𝑟𝑒𝑛𝑐𝑒 ), and the previous temperature offset ( 𝑇𝑜𝑓𝑓𝑠𝑒𝑡_𝑝𝑟𝑒𝑣𝑖𝑜𝑢𝑠 ) obtained using the _get_temperature_offset_ command (Section 3.7.2) . Recommended temperature offset values are between 0 °C and 20 °C. 

𝑇𝑜𝑓𝑓𝑠𝑒𝑡_𝑎𝑐𝑡𝑢𝑎𝑙 = 𝑇𝑆𝐶𝐷4𝑥 − 𝑇𝑅𝑒𝑓𝑒𝑟𝑒𝑛𝑐𝑒 + 𝑇𝑜𝑓𝑓𝑠𝑒𝑡_ 𝑝𝑟𝑒𝑣𝑖𝑜𝑢𝑠 (1) 

|**Write**|**Input paramete**|**r:**Offset temperature|**Response para**|**meter:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x241d|3|𝑤𝑜𝑟𝑑[0] = 𝑇𝑜𝑓𝑓𝑠𝑒𝑡[°𝐶] ∗<br>2<sup>16</sup>−1<br>175<br>|-|-|1|
|**Example:**set tem|perature offset to 5|.4 °C||||
|Write|0x241d|0x07e6<br>0x48||||
|_(hexadecimal)_|_Command_|_Toffset = 5.4 °C_<br>_CRC of 0x7e6_||||



**Table 13** : set_temperature_offset I<sup>2</sup> C sequence description 



#### **3.7.2 get_temperature_offset** 

|**Write**|**Input parameter:**-||**Response para**|**meter:**Offset temperature|Max.<br>|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|command<br>duration [ms]|
|0x2318|-|-|3|𝑇𝑜𝑓𝑓𝑠𝑒𝑡[°𝐶] = 𝑤𝑜𝑟𝑑[0] ∗<br>175<br>2<sup>16</sup>−1<br>|1|
|**Example:**tempe|rature offset is 6.2 °C|||||
|Write|0x2318|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution_|_time_|||
|Response|0x0912|0x63||||
|_(hexadecimal)_|_Toffset = 6.2 °C_|_CRC of 0x0912_||||



**Table 14** : get_temperature_offset I<sup>2</sup> C sequence description 

#### **3.7.3 set_sensor_altitude** 

**Description** : Reading and writing the sensor altitude must be done while the SCD4x is in idle mode. Typically, the sensor altitude is set once after device installation. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command must be issued. The default sensor altitude value is set to 0 meters above sea level. Valid input values are between 0 – 3’000 m. 

|**Write**|**Input paramete**|**r:**Sensor altitude|**Response para**|**meter:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2427|3|word[0]= Sensor altitude[m]|-|-|1|
|**Example:**set s|ensor altitude to 1’|950 m||||
|Write|0x2427|0x079e|0x09|||
|_(hexadecimal)_|_Command_|_Sensor altitude = 1’950 m_|_CRC of 0x079e_|||



**Table 15** : set_sensor_altitude I<sup>2</sup> C sequence description 

#### **3.7.4 get_sensor_altitude** 

**Description** : The _get_sensor_altitude_ command can be sent while the SCD4x is in idle mode to read out the previously saved sensor altitude value set by the _set_sensor_altitude_ command. 

|**Write**|**Input parameter:**-||**Response para**|**meter:**Sensor altitude|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2322|-|-|3|Sensor altitude[m]= word[0]|1|
|**Example:**sensor|altitude is 1’100 m|||||
|Write|0x2322|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution ti_|_me_|||
|Response|0x044c|0x42||||
|_(hexadecimal)_|_Sensor altitude = 1’100 m_|_CRC of 0x044c_||||



**Table 16** : get_sensor_altitude I<sup>2</sup> C sequence description 



#### **3.7.5 set_ambient_pressure** 

**Description** : The _set_ambient_pressure_ command can be sent during periodic measurements to enable continuous pressure compensation. Note that setting an ambient pressure overrides any pressure compensation based on a previously set sensor altitude. Use of this command is highly recommended for applications experiencing significant ambient pressure changes to ensure sensor accuracy. Valid input values are between 70’000 – 120’000 Pa. The default value is 101’300 Pa. The read/write bit that is part of the I<sup>2</sup> C header is used to differentiate between the _get_ambient_pressure_ and _set_ambient_pressure_ commands 

|**Write**|**Input paramete**|**r:**Ambient pressure|**Response param**|**eter:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0xe000|3|word[0] = ambient P [Pa] / 100|<br>-|-|1|
|**Example:**set am<br>Write|bient pressure to 98<br>0xe000|’700 Pa<br>0x03db|0x42|||
|_(hexadecimal)_|_Command_|_Ambient P = 98’700 Pa_|_CRC of 0x03db_|||



**Table 17** : set_ambient_pressure I<sup>2</sup> C sequence description 

#### **3.7.6 get_ambient_pressure** 

**Description** : The _get_ambient_pressure_ command can be sent during periodic measurements to read out the previously saved ambient pressure value set by the _set_ambient_pressure_ command. The read/write bit that is part of the I<sup>2</sup> C header is used to differentiate between the _get_ambient_pressure_ and _set_ambient_pressure_ commands. 

|**Write**|**Input parameter:**-||**Response para**|**meter:**Ambient pressure|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0xe000|-|-|3|ambient P[Pa]= word[0]* 100|1|
|**Example:**ambie|nt pressure is 98’700 Pa|||||
|Write|0xe000|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution t_|_ime_|||
|Response|0x03db|0x42||||
|_(hexadecimal)_|_Ambient P = 98’700 Pa_|_CRC of 0x03db_||||



**Table 18** : get_ambient_pressure I<sup>2</sup> C sequence description 



#### **3.8 Field Calibration** 

To achieve high initial and excellent long-term accuracy, the SCD4x includes two field calibration features: Forced recalibration (FRC) and automatic self-calibration (ASC). 

The ASC enables excellent long-term stability of SCD4x without the need for regular user intervention. The algorithm leverages the sensor’s measurement history and the assumption that the sensor is exposed to a known minimum background CO2 concentration at least once during a period of time accumulated while taking measurements. By default, the ASC algorithm assumes that the sensor, while taking measurements, was exposed to outdoor fresh air at 400 ppm CO2 concentration at least once for >3 minutes after every week of operation accumulated by using one of the following measurement modes for at least 4 hours at a time: periodic measurement mode (Section 3.6), low power periodic measurement mode (Section 3.9) or single shot mode with a measurement interval of 5 minutes (SCD41 and SCD43 only, see Section 3.11). 

Performing FRC restores high accuracy by providing the SCD4x with an externally obtained CO2 reference value. FRC can be applied to quickly correct the sensor’s output, e.g. if it is not possible to wait for and/or rely on ASC. 

#### **3.8.1 perform_forced_recalibration** 

**Description** : To successfully conduct an accurate FRC, the following steps need to be carried out: 

1. Operate the SCD4x in the operation mode later used for normal sensor operation (e.g. periodic measurement) for at least 3 minutes (single-shot mode: for > 3 single-shots at 1-minute measurement interval) in an environment with homogenous and constant CO2 concentration. The sensor must be operated at the voltage desired for the application when performing the FRC sequence. If applicable, the reference value for altitude or pressure compensation must be provided to the sensor beforehand. 

2. Issue the _stop_periodic_measurement_ command. Wait 500 ms for the command to complete. 

3. Issue the _perform_forced_recalibration_ command and optionally read out the FRC correction (i.e. the magnitude of the correction) after waiting for 400 ms for the command to complete. A return value of 0xffff indicates that the FRC has failed because the sensor was not operated before sending the command. 

|**Write**|**Input parameter:**T|arget CO2concentration|**Response param**|**eter:**FRC-correction|Max.<br>|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|command<br>duration [ms]|
|0x362f|3|word[0] = Target<br>concentration [ppm CO2]|3|FRC correction [ppm CO2]<br>= word[0] – 0x8000<br>word[0]  = 0xffff in case of<br>failed FRC|400|



**Example:** perform forced recalibration, providing a reference CO2 concentration of 480 ppm to a SCD4x sensor outputting 530 ppm. 

|Write|0x362f|0x01e0|0xb4|
|---|---|---|---|
|_(hexadecimal)_|_Command_|_Input: 480 ppm_|_CRC of 0x01e0_|
|Wait|400 ms|_command execution time_||
|Response|0x7fce|0x7b||
|_(hexadecimal)_|_Response: - 50 ppm_|_CRC of 0x7fce_||



**Table 19** : perform_forced_recalibration I<sup>2</sup> C sequence description 



#### **3.8.2 set_automatic_self_calibration_enabled** 

**Description** : sets the current state (enabled / disabled) of the ASC. By default, ASC is enabled. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command must be issued. 

|**Write**|**Input paramete**|**r:**ASC enabled|**Response para**|**meter:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2416|3|word[0] = 1 → ASC enabled<br>word[0] = 0 → ASC disabled|-|-|1|
|**Example:**set AS|C status: enabled|||||
|Write|0x2416|0x0001<br>0xb0||||
|_(hexadecimal)_|_Command_|_ASC enabled_<br>_CRC of 0x0001_||||



**Table 20** : set_automatic_self_calibration_enabled I<sup>2</sup> C sequence description. 

#### **3.8.3 get_automatic_self_calibration_enabled** 

|**Write**|**Input parameter:**-||**Response para**|**meter:**ASC enabled|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2313|-|-|3|word[0] = 1 → ASC enabled<br>word[0]= 0 → ASC disabled|1|
|**Example:**read A|SC status: disabled|||||



|Write|0x2313||
|---|---|---|
|_(hexadecimal)_|_Command_||
|Wait|1 ms|_command execution time_|
|Response|0x0000|0x81|
|_(hexadecimal)_|_ASC disabled_|_CRC of 0x0000_|



**Table 21** : get_automatic_self_calibration_enabled I<sup>2</sup> C sequence description 

#### **3.8.4 set_automatic_self_calibration_target** 

**Description** : sets the value of the ASC baseline target, i.e. the CO2 concentration in ppm which the ASC algorithm will assume as lower-bound background to which the SCD4x is exposed to regularly within one ASC period of operation. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command must be issued subsequently. 

|**Write**|**Input parameter**|**:**-||**Response param**|**eter:**|Max. command|
|---|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion||length  [bytes]|signal conversion|duration [ms]|
|0x243a|3|word[0] = ASC target [pp|m CO2]|-|-|1|
|**Example:**Set AS|C target to 435 ppm||||||
|Write|0x243a|0x01b3|0x9|9|||
|_(hexadecimal)_|_Command_|_ASC target = 435 ppm_|_CR_|_C of 0x01b3_|||



**Table 22** : set_automatic_self_calibration_target I<sup>2</sup> C sequence description 



#### **3.8.5 get_automatic_self_calibration_target** 

**Description** : reads out the ASC baseline target concentration parameter. The factory default value is 400 ppm. 

|**Write**|**Input parameter:**-||**Response para**|**meter:**ASC baseline target|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x233f|-|-|3|word[0] = ASC target [ppm CO2]|1|
|**Example:**ASC ta|rget is 420 ppm|||||
|Write|0x233f|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution_|_time_|||
|Response|0x01a4|0x4d||||
|_(hexadecimal)_|_ASC target is 420 ppm_|_CRC of 0x01a4_||||



**Table 23** : get_automatic_self_calibration_target I<sup>2</sup> C sequence description 

#### **3.9 Low Power Periodic Measurement Mode** 

To enable use-cases with a constrained power budget, the SCD4x features a low power periodic measurement mode with a signal update interval of approximately 30 seconds. The low power periodic measurement mode is initiated using the _start_low_power_periodic_measurement_ command and read-out in a similar manner as the periodic measurement mode using the _read_measurement_ command. Please consult Section 3.6.2 for further instructions. 

To periodically check whether a new measurement result is available for read out, the _get_data_ready_status_ command (Section 3.9.2) can be used to synchronize to the sensor’s internal measurement interval as an alternative to relying on the ACK/NACK status of the _read_measurement_command_ (Section 3.6.2) 

#### **3.9.1 start_low_power_periodic_measurement** 

**Description** : starts the low power periodic measurement mode. The signal update interval is approximately 30 seconds. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x21ac|-|-|-|-|not applicable|
|**Example:**start lo|w power periodic measur|ement||||
|Write|0x21ac|||||
|_(hexadecimal)_|_Command_|||||



**Table 24** : start_low_power_periodic_measurement I<sup>2</sup> C sequence description 



#### **3.9.2 get_data_ready_status** 

**Description** : polls the sensor for whether data from a periodic or single shot measurement is ready to be read out. 

|**Write**|**Input paramet**|**er:**-|**Response para**|**meter:**data ready status|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0xe4b8<br>**Example:**read|-<br>data ready status|-<br>: data not ready|3|If the least significant 11 bits of word[0] are:<br>0 → data not ready<br>else → data readyfor read-out|1|
|Write|0xe4b8|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution t_|_ime_|||
|Response|0x8000||0xa2|||
|_(hexadecimal)_|_Least significant_<br>_not ready_|_11 bits are 0 → data_|_CRC of 0x8000_|||



**Table 25** : get_data_ready_status I<sup>2</sup> C sequence description 

#### **3.10 Advanced Features** 

#### **3.10.1 persist_settings** 

**Description** : Configuration settings such as the temperature offset, sensor altitude and the ASC enabled/disabled parameters are by default stored in the volatile memory (RAM) only. The _persist_settings_ command stores the current configuration in the EEPROM of the SCD4x, ensuring the current settings persist after power-cycling. To avoid unnecessary wear of the EEPROM, the _persist_settings_ command should only be sent following configuration changes whose persistence is required. The EEPROM is guaranteed to withstand at least 2000 write cycles. Note that field calibration history (i.e. FRC and ASC, see Section 3.8) is automatically stored in a separate EEPROM dimensioned for the specified sensor lifetime when operated continuously in either periodic measurement mode (see Section 3.5.1), low power periodic measurement mode (see Section 3.9) or single shot mode with 5 minute measurement interval (SCD41 and SCD43 only, see Section 3.11). 

|**Write**|**Input parameter:**-||**Response parameter:**-||Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x3615|-|-|-|-|800|
|**Example:**persist|settings|||||
|Write|0x3615|||||
|_(hexadecimal)_|_Command_|||||



**Table 26** : persist_settings I<sup>2</sup> C sequence description 



#### **3.10.2 get_serial_number** 

**Description** : Reading out the serial number can be used to identify the chip and to verify the presence of the sensor. The _get_serial_number_ command returns 3 words, and every word is followed by an 8-bit CRC checksum. Together, the 3 words constitute a unique serial number with a length of 48 bits (in big endian format). 

|**Write**|**Input parameter:**-||**Response para**|**meter:**serial n|umber|Max. command|
|---|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]<br>signal conv|ersion|length  [bytes]|signal conve|rsion|duration [ms]|
|0x3682|-<br>-||9|Serial numb<br>word[1]<< 1|er = word[0] << 32 |<br>6|word[2]|1|
|**Example:**serial n<br>Write|umber is 273’325’796’834’238<br>0x3682||||||
|_(hexadecimal)_|_Command_||||||
|Wait|1 ms<br>_command ex_|_ecution t_|_ime_||||
|Response|0xf896<br>0x31|0x9f|07<br>0x|c2|0x3bbe|0x89|
|_(hexadecimal)_|_word[0]_<br>_CRC of 0xf896_|_word_|_[1]_<br>_CR_|_C of 0x9f07_|_word[2]_|_CRC of 0x3bbe_|



**Table 27** : get_serial_number I<sup>2</sup> C sequence description 

#### **3.10.3 perform_self_test** 

**Description** : The _perform_self_test_ command can be used as an end-of-line test to check the sensor functionality. 

|**Write**|**Input param**|**eter:**-|**Response para**|**meter:**sensor status|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length<br>[bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x3639|-|-|3|word[0] = 0 → no malfunction detected|10’000|
|||||word[0] ≠ 0 → malfunction detected||
|**Example:**perfor|m self-test, no m|alfunction detected||||



|Write|0x3639||
|---|---|---|
|_(hexadecimal)_|_Command_||
|Wait|10000 ms<br>_command_|_execution time_|
|Response|0x0000|0x81|
|_(hexadecimal)_|_No malfunction detected_|_CRC of 0x0000_|



**Table 28** : perform_self_test I<sup>2</sup> C sequence description 

#### **3.10.4 perfom_factory_reset** 

**Description** : The _perform_factory_reset_ command resets all configuration settings stored in the EEPROM and erases the FRC and ASC algorithm history. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x3632|-|-|-|-|1’200|
|**Example:**perfor|m factory reset|||||
|Write|0x3632|||||
|_(hexadecimal)_|_Command_|||||



**Table 29** : perform_factory_reset I<sup>2</sup> C sequence description 



#### **3.10.5 reinit** 

**Description** : The _reinit_ command reinitializes the sensor by reloading user settings from EEPROM. The sensor must be in the idle state before sending the _reinit_ command. If the _reinit_ command does not trigger the desired re-initialization, a power-cycle should be applied to the SCD4x. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x3646|-|-|-|-|30|
|**Example:**reinit||||||
|Write|0x3646|||||
|_(hexadecimal)_|_Command_|||||



**Table 30** : reinit I<sup>2</sup> C sequence description 

#### **3.10.6 get_sensor_variant** 

**Description** : reads out the SCD4x sensor variant (e.g. SCD40, SCD41 or SCD43). 

|**Write**|**Input parameter:**-||**Response para**|**meter:**sensor variant|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x202f|-|-|3|Word[0]:<br>Bits[15…12] = 0000 → SCD40<br>Bits[15…12] = 0001 → SCD41<br>Bits[15…12]= 0101 → SCD43|1|
|Write|0x202f|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution time_||||
|**Example:**senso|r variant is SCD41. Respons|e bits 0…11 maydiffer fr|om this example|||
|Response|0x1440|0x51||||
|_(hexadecimal)_|_Product version = SCD41_|_CRC of 0x1440_||||
|**Example:**senso<br>|r variant is SCD40. Respons<br>|e bits 0…11 maydiffer fr<br>|om this example|||
|Response|0x0440|0x3F||||
|_(hexadecimal)_|_Product version = SCD40_|_CRC of 0x0440_||||
|**Example:**senso<br>|r variant is SCD43. Respons<br>|e bits 0…11 may differ fr<br>|om this example|||
|Response|0x5441|0xE9||||
|_(hexadecimal)_|_Product version = SCD43_|_CRC of 0x5441_||||



**Table 31** : get_sensor_variant I<sup>2</sup> C sequence description 



#### **3.11 Single Shot Measurement Mode (SCD41 & SCD43 only)** 

The SCD41 and SCD43 additionally feature a single shot measurement mode for on-demand measurements. The typical communication sequence is as follows: 

1. The sensor is powered up with the _wake_up_ command if previously powered down using the _power_down_ command. 

2. The I<sup>2</sup> C master sends a _measure_single_shot_ command and waits for the indicated _max. command duration_ time. 

3. The I<sup>2</sup> C master reads out data with the _read_measurement_ command (3.6.2) after the specified _max. command duration_ time. 

4. Repeat steps 2–3 as required by the application. 

5. If desired, power down the sensor with the _power_down_ command. 

To reduce noise levels, the I<sup>2</sup> C master can perform several single shot measurements in a row and average the CO2 output values. Note: The fastest possible sampling interval for single shot measurements is 5 seconds. 

The ASC is enabled by default in single shot operation and optimized for single shot measurements performed every 5 minutes. Longer or shorter single shot measurement intervals will result in less or more frequent ASC corrections, respectively. To adapt the ASC parameters for measurement intervals other than 5 minutes, the ASC initial and standard period length parameters can be adjusted (see relevant commands in following subsections and relevant supporting documentation<sup>19</sup> ). The standard period represents the cumulative duration of the sensor in measurement mode, tracked in blocks of 4 hours, periodically triggering automatic self-calibration. If operated for the very first time, or following a _perform_factory_reset_ command, the shorter initial period parameter is used exactly and only once. 

Note that, for single shot operation with ASC enabled and measurement intervals of less than 5 minutes, the lifetime of EEPROM used by the ASC is reduced proportionally. 

To further reduce the sensor’s power consumption, the sensor may be power cycled between measurements either by cutting/reapplying the supply and I<sup>2</sup> C voltages or by using the _power_down/wake_up_ commands. Note that for power-cycled single shot operation, ASC functionality is not available in either case. 

#### **3.11.1 measure_single_shot** 

**Description** : on-demand measurement of CO2 concentration, relative humidity and temperature. The sensor output is read out by using the _read_measurement_ command (Section 3.6.2). 

|**Write**|**Input parameter:**-||**Response parameter:**-||Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x219d|-|-|-|-|5’000|
|**Example:**measu|re single shot|||||
|Write|0x219d|||||
|_(hexadecimal)_|_Command_|||||



**Table 32** : measure_single_shot I<sup>2</sup> C sequence description 

> 19 More information on ASC settings and SCD4x low power modes can be found in the application note on “Low Power Operation SCD4x” 



#### **3.11.2 measure_single_shot_rht_only** 

**Description** : on-demand measurement of relative humidity and temperature only, significantly reduces power consumption. The sensor output is read out by using the _read_measurement_ command (Section 3.6.2). CO2 output is returned as 0 ppm. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2196|-|-|-|-|50|
|**Example:**measu|re single shot, RH and T|output only||||
|Write|0x2196|||||
|_(hexadecimal)_|_Command_|||||



**Table 33** : measure_single_shot_rht_only I<sup>2</sup> C sequence description 

#### **3.11.3 power_down** 

**Description** : put the sensor from idle to sleep to reduce current consumption. Can be used to power down when operating the sensor in power-cycled single shot mode. 

|**Write**|**Input parameter:**-||**Response paramet**|**er:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x36e0|-|-|-|-|1|
|**Example:**power|down the sensor|||||
|Write|0x36e0|||||
|_(hexadecimal)_|_Command_|||||



**Table 34** : power_down I<sup>2</sup> C sequence description 

#### **3.11.4 wake_up** 

**Description** : wake up the sensor from sleep mode into idle mode. Note that the SCD4x does not acknowledge the _wake_up_ command. The sensor’s idle state after wake up can be verified by reading out the serial number (Section 3.10.2). 

|**Write**|**Input parameter:**-||**Response parameter:**-||Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x36f6|-|-|-|-|30|
|**Example:**wake u|p the sensor|||||
|Write|0x36f6|||||
|_(hexadecimal)_|_Command_|||||



**Table 35:** wake_up I<sup>2</sup> C sequence description 



#### **3.11.5 set_automatic_self_calibration_initial_period** 

**Description** : sets the duration of the initial period for ASC correction (in hours). By default, the initial period for ASC correction is 44 hours. Allowed values are integer multiples of 4 hours. A value of 0 results in an immediate correction. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command must be issued. 

Note: For single shot operation, this parameter always assumes a measurement interval of 5 minutes, counting the number of single shots to calculate elapsed time. If single shot measurements are taken more / less frequently than once every 5 minutes, this parameter must be scaled accordingly to achieve the intended period in hours (e.g. for a 10-minute measurement interval, the scaled parameter value is obtained by multiplying the intended period in hours by 0.5). 

|**Write**|**Input paramete**|**r:**ASC initial pe|riod|**Response para**|**meter:**-|Max. command|
|---|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conver|sion|length  [bytes]|signal conversion|duration [ms]|
|0x2445|3|word[0] = AS<br>[hours]|C initial period|-|-|1|
|**Example:**write A|SC initial period of|76 hours|||||
|Write|0x2445|0x004c|0xc1||||
|_(hexadecimal)_|_Command_|_Initial period_<br>_76 hours_|_CRC of 0x004c_||||



**Table 36** : set_automatic_self_calibration_initial_period I<sup>2</sup> C sequence description 

#### **3.11.6 get_automatic_self_calibration_initial_period** 

|**Write**|**Input parameter:**-||**Response para**|**meter:**ASC initial period|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x2340|-|-|3|ASC initial period [hours] =<br>word[0]|1|
|**Example:**read A|SC initial period of 76 h|ours||||
|Write|0x2340|||||
|_(hexadecimal)_|_Command_|||||
|Wait|1 ms|_command execution ti_|_me_|||
|Response|0x004c|0xc1||||
|_(hexadecimal)_|_76 hours_|_CRC of 0x004c_||||



**Table 37** : get_automatic_self_calibration_initial_period I<sup>2</sup> C sequence description 



#### **3.11.7 set_automatic_self_calibration_standard_period** 

**Description** : sets the standard period for ASC correction (in hours). By default, the standard period for ASC correction is 156 hours. Allowed values are integer multiples of 4 hours. Note: a value of 0 results in an immediate correction. To save the setting to the EEPROM, the _persist_settings_ (see Section 3.10.1) command must be issued. 

Note: For single shot operation, this parameter always assumes a measurement interval of 5 minutes, counting the number of single shots to calculate elapsed time. If single shot measurements are taken more / less frequently than once every 5 minutes, this parameter must be scaled accordingly to achieve the intended period in hours (e.g. for a 10-minute measurement interval, the scaled parameter value is obtained by multiplying the intended period in hours by 0.5). 

|**Write**|**Input paramete**|**r:**ASC standard period|**Response**|**parameter:**-|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length<br>[bytes]|signal conversion|duration [ms]|
|0x244e|3|word[0] = ASC standard period<br>[hours]|-|-|1|
|**Example:**set aut<br>Write|omatic self-calibrati<br>0x244e|on standard period of 156 hours<br>0x009c<br>0xc5||||
|_(hexadecimal)_|_Command_|_Standard_<br>_period_<br>_156 hours_<br>_CRC of 0x009c_||||



**Table 38** : set_automatic_self_calibration_standard_period I<sup>2</sup> C sequence description 

#### **3.11.8 get_automatic_self_calibration_standard_period** 

|**Write**|**Input parameter:**-||**Response para**|**meter:**ASC standard period|Max. command|
|---|---|---|---|---|---|
|(hexadecimal)|length  [bytes]|signal conversion|length  [bytes]|signal conversion|duration [ms]|
|0x234b|-|-|3|word[0] = ASC standard<br>period [hours]|1|



**Example:** read ASC standard period of 156 hours 

|Write|0x234b||
|---|---|---|
|_(hexadecimal)_|_Command_||
|Wait|1 ms|_command execution time_|
|Response|0x009c|0xc5|
|_(hexadecimal)_|_Standard period_|_CRC of 0x009c_|
||_156 hours_||



**Table 39** : get_automatic_self_calibration_standard_period I<sup>2</sup> C sequence description 



#### **3.12 Checksum Calculation** 

The 8-bit CRC checksum transmitted after each data word is generated by a CRC algorithm. Its properties are displayed in **Table 40** . The CRC covers the contents of the two previously transmitted data bytes. To calculate the checksum only these two previously transmitted data bytes are used. Note that command words are not followed by CRC. 

|**Property**|**Value**|**Example code(C/C++)**|
|---|---|---|
|Name|CRC-8|**#define CRC8_POLYNOMIAL 0x31**<br>**#define CRC8INIT 0xff**|
|Width|8 bit|**_**|
|Protected Data|read and/or write data|**uint8_t sensirion_common_generate_crc(const uint8_t* data, uint16_t count) {**<br> **uint16tcurrentbyte;**|
|Polynomial|0x31(x<sup>8</sup>+ x<sup>5</sup>+ x<sup>4</sup>+ 1)|**__**<br>**uint8_tcrc= CRC8_INIT;**<br>|
|Initialization|0xff|**uint8_tcrc_bit;**<br>**/* calculates 8-Bit checksum with given polynomial */**|
|Reflect input|False|<br> **for (current_byte= 0; current_byte< count; ++current_byte) {**<br> **^**|
|Reflect output|False|**crc= (data[current_byte]);**<br> **for (crc_bit= 8; crc_bit> 0; --crc_bit) {**|
|Final XOR|0x00|**if (crc& 0x80)**<br>   **^**|
|Examples|CRC (0xbeef) = 0x92|**crc= (crc<<1)CRC8_POLYNOMIAL;**<br> **else**<br>**crc= (crc<<1);**<br> **}**<br>**}**<br> **return crc;**<br>**}**|



**Table 40** : I<sup>2</sup> C CRC properties 



<!-- Start of picture text -->
SENSIRION<br><!-- End of picture text -->

### **4 Mechanical Specifications** 

#### **4.1 Package Outline** 

**Figure 3** schematically displays the sensor’s package outline, as well as key nominal dimensions and their tolerances in millimeters. A circular mark and a notched corner of the protective membrane serve as polarity marks to indicate the location of pin 1. The white protective membrane on top of the sensor must not be removed or tampered with to ensure proper sensor operation. The weight of the sensor is approx. 0.6 g. 



<!-- Start of picture text -->
5.5203<br>:<br>= ‘ | eee | a<br>| ym<br>|| ° ABULS tf;<br>: ! Yoooo | a7<br><!-- End of picture text -->

**Figure 3** : Sensor package dimensions of SCD4x: top, side and bottom view (left to right, projection method 1). All dimensions in millimeters. 

#### **4.2 Land Pattern Recommendation** 

Recommended land pattern, solder paste, and solder mask are shown in **Figure 4** . The exact mask geometries, distances and stencil thicknesses must be adapted to the customer soldering processes. In any case, the keep-free area around the thermal relief hole of the sensor must be respected. 



<!-- Start of picture text -->
a b c<br>48 As 03 0.18 1.25 1.25 0.31, 5 AT,<br>Pr | Tt. rr<br>| 4 (_) core L) ol<br>— WOOO) | © @ .jogo00 s OOO | -<br>7 | (| o o »| (Co Co<br>= Cy] 2 ie LIL) Ss) 4 ol o<br>S oo000 Cc) ¢ 'dobork) om)| =oo000oO<br><!-- End of picture text -->

**Figure 4** : Recommended SCD4x footprint (top view): landing pads ( **a** ), solder paste ( **b** ) and solder mask ( **c** ). All dimensions in millimeters. 



#### **4.3 Tape & Reel Package** 

**Figure 5** details the tape and reel package specifications. Reels are 7 inches and 13 inches in diameter for the 60-piece and 600-piece package sizes, respectively. 



<!-- Start of picture text -->
2.0040, SEE NOTE 2 1600 50°?5 1,7520.1<br>. “400 SEE NOTE | 50 MIN<br>R0.30 MAX 3,0 0/0 0,0 o|S 00 OT FB OOD O00 T<br>| AA Bo<br>Det SS SF ees SS aa<br>1 Y N NU No+$Ni 40%.1<br>- ko Cc °<br>-140-—4<br>SECTION 8-8 YT men<br>Ly __<br>7a s) OK PINs<br>Dm | + SECTION AA A Q——,4, S\<br>Ao) 10,60 | 0. ay<br>Bo) 10,60 | 0.1 (—*<br>Ko! 690 [0 |||<br>verac NELh<br><!-- End of picture text -->

**Figure 5** : Technical drawing of the packaging tape with sensor orientation in tape. In the drawing, header tape is to the right and trailer tape to the left. All dimensions in millimeters. 

#### **4.4 Moisture Sensitivity Level** 

Sensirion SCD4x sensors must be treated according to Moisture Sensitivity Level 1 (MSL1) as per IPC/JEDEC J-STD-033B1. The manufacturing floor time (out of bag) at the customer’s end is not limited under normal factory conditions (≤30 °C and 85 %RH). It is recommended to process the sensors within one year of the date of delivery. Exposure to moisture levels or solder reflow temperatures which exceed the limits as stated in this document can result in yield loss and reliability degradation<sup>20</sup> . 

> 20 More information on SCD4x packing and storage can be found in the user guide “Handling Instructions SCD4x” 



<!-- Start of picture text -->
SENSIRION<br><!-- End of picture text -->

#### **4.5 Soldering Instructions** 

The sensors are designed to withstand a soldering profile based on IPC/JEDEC J-STD-020, with a maximum peak temperature of 245 °C up to 30 sec and Pb-free assembly in IR/Convection reflow ovens. See **Table 41** for more details. 

Note that due to the size and shape of the SCD4x sensor, significant temperature differences across the sensor element can occur during reflow soldering. Specifically, the temperature within the sensor cap can be higher than the temperature measured at the pad using usual temperature monitoring methods. Care must be taken that a temperature of 245°C is not exceeded at any time in any part of the sensor. 

The SCD4x is not compatible with vapor phase reflow soldering. The dust cover on top of the cap must not be removed or wetted with any liquid. Do not apply extra flux during the reflow soldering nor reflow solder more than once. Do not apply any board wash process step subsequently to the reflow soldering<sup>21</sup> . 

Minor temporary accuracy deviations of the CO2 reading can result from the reflow soldering of the SCD4x. Full sensor accuracy is restored after at most five days after the soldering process, independently of whether the sensor is operated or not. 

|**Average ramp-up rate**|< 3 °C / second|
|---|---|
|**Liquid phase**<br>▪<br>TL|> 220 °C|
|▪<br>tL|< 60 seconds|
|**Peak temperature**||
|▪<br>TP|≤ 245°C|
|▪<br>tP|< 30 seconds|
|**Ramp-down rate**|< 4 °C / second for<br>temperature > TL|





**Table 41** : Soldering profile parameters 

#### **4.6 Traceability and Identification** 

All SCD4x sensors have a distinct electronic serial number for identification and traceability (see Section 3.10.2). The serial number can be decoded by Sensirion only and allows for tracking through production, calibration, and testing. 

All SCD4x sensors include a laser marking on the sidewall of the sensor cap. The laser marking contains the product variant (i.e., SCD40, SCD41 or SCD43) and the product serial number within a data matrix ( **Figure 6** ). 



<!-- Start of picture text -->
(T_T)<br>1faSCD41 |<br><!-- End of picture text -->

**Figure 6:** Illustration of a laser marking with product type and data matrix on the sidewall of the sensor cap. 

> 21 More information on SCD4x reflow soldering can be found in the user guide “Handling Instructions SCD4x” 



### **5 Ordering Information** 

Use the part names and product numbers shown in **Table 42** when ordering the SCD4x CO2 sensor. For the latest product information and local distributors, please visit the Sensirion website. 

|**Part Name**|**Description**|**Ordering quantity (pcs)**|**Product Number**|
|---|---|---|---|
|SCD40-D-R1|SCD40 CO2 sensor SMD component as reel, I2C|60 sensors per reel|3.000.496|
|SCD40-D-R2|SCD40 CO2 sensor SMD component as reel, I2C|600 sensors per reel|3.000.521|
|SCD41-D-R1|SCD41 CO2 sensor SMD component as reel, I2C|60 sensors per reel|3.000.960|
|SCD41-D-R2|SCD41 CO2 sensor SMD component as reel, I2C|600 sensors per reel|3.000.961|
|SCD43-D-R2|SCD43 CO2 sensor SMD component as reel, I2C|600 sensors per reel|3.001.241|
|SEK-SCD41-Sensor|SEK-SCD41-Sensor set; SCD41 on development<br>board with cables|1|3.000.455|
|SEK-SCD43-Sensor|SEK-SCD43-Sensor set; SCD43 on development<br>board with cables|1|3.001.244|
|SEK-SensorBridge|Sensor Bridge to connect SEK-SCD4x-Sensor to<br>computer|1|3.000.124|



**Table 42** : Part names and product numbers for ordering SCD4x 

#### **5.1 Historical Information** 

The parts / product numbers of the SCD4x product family shown in **Table 43** are obsolete. 

|**Period Active**|**Product Number**|**Note**|
|---|---|---|
|Before 01.08.2023|3.000.497|For applicable specifications, see Version 1.3 of the SCD4x Datasheet|
|Before 01.08.2023|3.000.498|For applicable specifications, see Version 1.3 of the SCD4x Datasheet|



**Table 43:** Obsolete ordering information 



### **<u>6 Revision History</u>** 

|**Date**<br>January2021|**Version **<br>1|**Page(s)**<br>all|**Changes**<br>Initial release|
|---|---|---|---|
|April 2021|1.1|16 - 17|Adjustment max. command time self-test (Section 3.9) and single shot (Section 3.10),<br>minor revisions on otherpages|
|May 2022|1.2|3<br>12<br>18<br>22<br>all|Clarification on additional sensor accuracy drift (Table 1)<br>Clarification of set_ambient_pressure command description (Section 3.7.5)<br>Addition of power_down and wake_up commands (Section 3.11)<br>Addition of minor temporary accuracy deviation after reflow soldering (Section 4.5)<br>Minor editorial revisions|
|September 2022|1.3|1,22<br>All|Correction of hyperlink<br>Minor editorial revisions|
|February 2023|1.4|3<br>4<br>5<br>6<br>7<br>8<br>10<br>11<br>12<br>17<br>19<br>20<br>22<br>24<br>All|Updated SCD41 accuracy values, updated drift parameters and drift conditions (Table 1),<br>correction of tolerance in footnote #2, clarification of footnotes #2, 4 and 5<br>Clarification of operation mode per average supply current (Table 4), additional information<br>on ESD HBM (Table 5), additional footnote #8, clarification of footnotes #7 and 12<br>Clarification of recommendations on power supply for sensor operation (Section 2.3)<br>Correction of power-up time and soft reset time, increase of maximum SCL clock frequency<br>to 400 kHz (Section 2.4)<br>Minor editorial revisions for clarification (Section 3.1)<br>Addition of get_ambient_pressure, set_automatic_self_calibration_initial_period,<br>get_automatic_self_calibration_initial_period,<br>set_automatic_self_calibration_standard_period,<br>get_automatic_self_calibration_standard_period~~and set_automatic_self_calibration_target~~<br>commands (Table 9), correction of reinit and wake_up execution times (Section 3.4)<br>Addition of recommended temperature offset range, formula correction of signal conversion<br>(Section 3.6.1)<br>Formula correction of signal conversion (Section 3.6.2), addition of valid sensor altitude<br>input values (Section 3.6.3)<br>Addition of valid ambient pressure input values to set_ambient_pressure command<br>(Section 3.6.5) and addition of get_ambient_pressure command (Section 3.6.6)<br>Correction of reinit max. command duration (Section 3.9.5), clarification of typical<br>communication sequence for single shot measurement mode (Section 3.10)<br>Correction of wake_up max. command duration (Section 3.10.4), addition of<br>set_automatic_self_calibration_initial_period (Section 3.10.5) and<br>get_automatic_self_calibration_initial_period commands (Section 3.10.6)<br>Addition of set_automatic_self_calibration_standard_period command (Section 3.10.7) and<br>get_automatic_self_calibration_standard_period command (Section 3.10.8)<br>Additional information on white protection membrane (Section 4.1)<br>Increase of peak reflow soldering temperature to 245°C, clarification of soldering guidance<br>(Section 4.5), addition of information concerning product laser marking (Section 4.6)<br>Minor editorial revisions|
|July 2023|1.5|4<br>15<br>19, 20<br>22<br>25<br>All|Clarified description of supply voltage ripple specification (Section 2, Table 4)<br>Addition of description for get_data_ready_status command (Section 3.8.2)<br>Clarification on ASC availability in power-cycled single shot operation (Section 3.10),<br>Addition of clarification on ASC period parameter scaling for single shot operation<br>(Sections 3.10.5 and 3.10.7)<br>Moved dimensions into Figure 3, removed separate table with dimensions (Section 4.1)<br>Updated product numbers for SCD41, addition of historical ordering information (Section 5)<br>Minor editorial revisions|
|September 2024|1.6|1<br>3<br>4|<br>Updated visuals and product summary, corrected block diagram, added footnotes #1-3<br>Clarification of default conditions, clarification of conditions for response time specification<br>and description of drift specification (Table 1), clarified measurement mode condition for<br>RH/T response time specification and moved previous footnote #5 into prose text (Sections<br>1.2 and 1.3), clarification of footnotes #6-8(prev. footnotes 2-4).<br>Changed moisture sensitivity level specification to MSL Level 1 (Section 2.2, Table 5)<br>Clarification of footnote #15 (prev. footnote 12)|





|||5<br>7<br>8<br>9<br>10<br>13<br>14<br>15<br>16<br>18<br>21<br>22<br>24<br>25<br>All|Clarification of recommendations on power supply for sensor operation and of I<sup>2</sup>C<br>specification (Section 2.3)<br>Moved Table 8 into separate new sub-section clarifying sensor I<sup>2</sup>C address (Section 3.2)<br>Addition of set_automatic_self_calibration_target, get_automatic_self_calibration_target<br>and get_sensor_variant commands to Table 9 (Section 3.5)<br>Clarified typical communication sequence description (Section 3.6)<br>Clarified description of stop_periodic_measurement command (Section 3.6.3)<br>Clarified description of on-chip output signal compensation (Section 3.7) and<br>set_temperature_offset command (Section 3.7.1)<br>Clarified and expanded information on ASC functionality and conditions for use with default<br>parameters (Section 3.8)<br>Addition of set_automatic_self_calibration_target command (Section 3.8.4)<br>Addition of get_automatic_self_calibration_target command (Section 3.8.5)<br>Clarified note on EEPROM lifetime conditions for operation with ASC (Section 3.10.1)<br>Addition of get_sensor_variant command (Section 3.10.6)<br>Addition of note on shortest possible single shot measurement interval, clarified impact of<br>single shot measurement interval on ASC functionality and EEPROM lifetime, removed<br>recommendation to discard initial single shot measurement after power cycle (Section 3.11)<br>Clarified note on ASC initial period parameter adaption based on single shot measurement<br>interval (Section 3.11.5)<br>Clarified note on ASC standard period parameter adaption based on single shot<br>measurement interval (Section 3.11.7)<br>Clarified note on polarity marking of the sensor, updated Figure 3 to add bottom view with<br>respective dimensions (Section 4.1)<br>Addition of note on sensor thermal relief hole and respective keep free area, updated<br>Figure 4 for clarity (Section 4.2)<br>Addition of reel diameters (Section 4.3).<br>Updated moisture sensitivity level specification from MSL3 to MSL1, adapted out of bag<br>manufacturing floor time conditions in accordance with MSL1, removed table specifying<br>baking conditions for MSL3 (Section 4.4)<br>Minor editorial revisions|
|---|---|---|---|
|April 2025|1.7|1<br>13<br>All|Updated product summary, added product visual for SCD43, Updated & reordered<br>footnotes #1-3, Addition of new footnote #4<br>Clarified section on ASC functionality (Section 3.8), Added note on pressure/altitude<br>compensation for conducting FRC (Section 3.8.1)<br>Addition of specifications for SCD43<br>Minor editorial revisions and clarifications|





### **Important Notices** 

##### **Warning, Personal Injury** 

**Do not use this product as safety or emergency stop devices or in any other application where failure of the product could result in personal injury (including death). Do not use this product for applications other than its intended and authorized use. Before installing, handling, using or servicing this product, please consult the data sheet and application notes. Failure to comply with these instructions could result in death or serious injury.** 

If the Buyer shall purchase or use SENSIRION products for any unintended or unauthorized application, Buyer shall defend, indemnify and hold harmless SENSIRION and its officers, employees, subsidiaries, affiliates and distributors against all claims, costs, damages and expenses, and reasonable attorney fees arising out of, directly or indirectly, any claim of personal injury or death associated with such unintended or unauthorized use, even if SENSIRION is allegedly negligent with respect to the design or the manufacture of the product. 

##### **ESD Precautions** 

The inherent design of this component causes it to be sensitive to electrostatic discharge (ESD). To prevent ESD-induced damage and/or degradation, take customary and statutory ESD precautions when handling this product. See application note “ESD, Latchup and EMC” for more information. 

##### **Warranty** 

SENSIRION solely warrants to the original purchaser of this product for a period of 12 months (one year) from the date of delivery that this product is of the quality, material and workmanship defined in SENSIRION’s published specifications of the product. Within such period, if proven to be defective, SENSIRION shall as sole and exclusive remedy, in SENSIRION’s discretion, repair this product or send a replacement product, free of charge to the Buyer, provided that: 

- notice in writing describing the defects shall be given to SENSIRION within fourteen (14) days after their appearance; 

- such defects shall be found, to SENSIRION’s reasonable satisfaction, to have arisen from SENSIRION’s faulty design, material, or workmanship; 

- the defective product shall be returned to SENSIRION’s factory at the Buyer’s expense; and 

- the warranty period for any repaired or replaced product shall be limited to the unexpired portion of the original period. 

The Buyer shall at its own expense arrange for any dismantling and reassembly that is necessary to repair or replace the defective product. This warranty does not apply to any equipment which has not been installed or used within the specifications recommended by SENSIRION. EXCEPT FOR THE WARRANTIES EXPRESSLY SET FORTH HEREIN, SENSIRION MAKES NO WARRANTIES, EITHER EXPRESS OR IMPLIED, WITH RESPECT TO THE PRODUCT. ANY AND ALL WARRANTIES, INCLUDING WITHOUT LIMITATION, WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, ARE EXPRESSLY EXCLUDED AND DECLINED. 

SENSIRION is only liable for defects of this product arising under the conditions of operation provided for in the data sheet and proper use of the goods. SENSIRION explicitly disclaims all warranties, express or implied, if the goods are operated or stored not in accordance with the technical specifications. 

SENSIRION does not assume any liability arising out of any application or use of any product or circuit and specifically disclaims any and all liability, including without limitation indirect, consequential, and incidental damages, and loss of profit. No obligation or liability shall arise or grow out of SENSIRION’s rendering of technical advice, consulting, or implementation instructions or guidelines. All operating parameters, including without limitation recommended parameters, must be validated for each Buyer’s applications by the Buyer’s technical experts. Recommended parameters can and do vary in different applications. 

SENSIRION reserves the right, without further notice, (i) to change the product specifications and/or the information in this document and (ii) to improve reliability, functions and design of this product. 

### **Headquarters and Subsidiaries** 

**Sensirion AG Sensirion Inc., USA** Laubisruetistr. 50 phone: +1 312 690 5858 CH-8712 Staefa ZH <u>info-us@sensirion.com</u> Switzerland <u>www.sensirion.com</u> phone: +41 44 306 40 00 **Sensirion Japan Co. Ltd.** fax: +41 44 306 40 30 phone: +81 45 270 4506 <u>info@sensirion.com info-jp@sensirion.com www.sensirion.com www.sensirion.com/jp</u> 

**Sensirion Korea Co. Ltd.** phone: +82 31 337 7700~3 <u>info-kr@sensirion.com www.sensirion.com/kr</u> 

**Sensirion China Co. Ltd.** phone: +86 755 8252 1501 <u>info-cn@sensirion.com www.sensirion.com/cn</u> 

**Sensirion Taiwan Co. Ltd** phone: +886 2 2218-6779 <u>info@sensirion.com</u> To find your local representative, please visit <u>www.sensirion.com www.sensirion.com/distributors</u> 

Copyright © 2025, by SENSIRION. CMOSens<sup>®</sup> and PASens<sup>®</sup> are trademarks of Sensirion. All rights reserved. 

