# **Data Sheet** 

### **Description** 

The APDS-9960 device features advanced Gesture detection, Proximity detection, Digital Ambient Light Sense (ALS) and Color Sense (RGBC). The slim modular package, L 3.94 x W 2.36 x H 1.35 mm, incorporates an IR LED and factory calibrated LED driver for drop-in compatibility with existing footprints. 

#### **Gesture detection** 

Gesture detection utilizes four directional photodiodes to sense reflected IR energy (sourced by the integrated LED) to convert physical motion information (i.e. velocity, direction and distance) to a digital information. The architecture of the gesture engine features automatic activation (based on Proximity engine results), ambient light subtraction, cross-talk cancelation, dual 8-bit data converters, power saving inter-conversion delay, 32-dataset FIFO, and interrupt driven I2C communication. The gesture engine accommodates a wide range of mobile device gesturing requirements: simple UP-DOWN-RIGHT-LEFT gestures or more complex gestures can be accurately sensed. Power consumption and noise are minimized with adjustable IR LED timing. 

Description continued on next page... 

### **Applications** 

- Gesture Detection 

- Color Sense 

### **Features** 

   - Ambient Light and RGB Color Sensing, Proximity Sensing, and Gesture Detection in an Optical Module 

   - Ambient Light and RGB Color Sensing 

      - UV and IR blocking filters 

      - Programmable gain and integration time 

      - Very high sensitivity – Ideally suited for operation behind dark glass 

   - Proximity  Sensing 

      - Trimmed to provide consistent reading 

      - Ambient light rejection 

      - Offset compensation 

      - Programmable driver for IR LED current 

      - Saturation indicator bit 

   - Complex Gesture Sensing 

      - Four separate diodes sensitive to different directions 

      - Ambient light rejection 

      - Offset compensation 

      - Programmable driver for IR LED current 

      - 32 dataset storage FIFO 

      - Interrupt driven I2C communication 

   - I2C-bus Fast Mode Compatible Interface 

      - Data Rates up to 400 kHz 

      - Dedicated Interrupt Pin 

   - Small Package L 3.94 × W 2.36 × H 1.35 mm 

- Ambient Light Sensing 

- Cell Phone Touch Screen Disable 

- Mechanical Switch Replacement 

### **Ordering Information** 

|**Part Number**<br>APDS-9960|**Packaging**<br>Tape & Reel|**Quantity**<br>2500per reel|
|---|---|---|



### **Description (Cont.)** 

### **Proximity detection** 

The Proximity detection feature provides distance measurement (E.g. mobile device screen to user’s ear) by photodiode detection of reflected IR energy (sourced by the integrated LED). Detect/release events are interrupt driven, and occur whenever proximity result crosses upper and/ or lower threshold settings. The proximity engine features offset adjustment registers to compensate for system offset caused by unwanted IR energy reflections appearing at the sensor. The IR LED intensity is factory trimmed to eliminate the need for end-equipment calibration due to component variations. Proximity results are further improved by automatic ambient light subtraction. 

### **Color and ALS detection** 

The Color and ALS detection feature provides red, green, blue and clear light intensity data. Each of the R, G, B, C channels have a UV and IR blocking filter and a dedicated data converter producing16-bit data simultaneously. This architecture allows applications to accurately measure ambient light and sense color which enables devices to calculate color temperature and control display backlight. 

### **Functional Block Diagram** 



<!-- Start of picture text -->
VDD<br>LED A<br>Oscillator<br>LED K<br>Clear RGBC<br>LDR Red<br>ALS<br>GND Green ADC SCL<br>Blue<br>SDA<br>Up Gesture<br>Engine<br>Down 32 x 4 Byte<br>FIFO<br>Left Proximity<br>Engine<br>Right<br>PWM Threshold<br>Control<br>Interrupt INT<br>MUX<br>2C InterfaceI<br><!-- End of picture text -->

#### **I/O Pins Configuration** 

|**Pin**|**Name**|**Type**|**Description**|
|---|---|---|---|
|1|SDA|I/O|I<sup>2</sup>C serial data I/O terminal - serial data I/O for I<sup>2</sup>C-bus|
|2|INT|O|Interrupt - open drain (active low)|
|3|LDR||LED driver input forproximityIR LED, constant current source LED driver|
|4|LEDK||LED Cathode, connect to LDRpin when usinginternal LED driver circuit|
|5|LEDA||LED Anode, connect to VLEDAon PCB|
|6|GND||Power supply ground. All voltages are referenced to GND|
|7|SCL|I|I<sup>2</sup>C serial clock input terminal - clock signal for I<sup>2</sup>C serial data|
|8|VDD||Power supplyvoltage|



#### **Absolute Maximum Ratings over operating free-air temperature range (unless otherwise noted)**<sup>*****</sup> 

|**Parameter**|**Symbol**|**Min**|**Max**|**Units**|**Conditions**|
|---|---|---|---|---|---|
|Power supplyvoltage<sup>[1]</sup>|VDD||3.8|V||
|Input voltage range|VIN|-0.5|3.8|V||
|Output voltage range|VOUT|-0.3|3.8|V||
|Storage temperature range|Tstg|-40|85|°C||



* Stresses beyond those listed under “absolute maximum ratings” may cause permanent damage to the device. These are stress ratings only and functional operation of the device at these or any other conditions beyond those indicated under “recommended operating conditions” is not implied. Exposure to absolute-maximum-rated conditions for extended periods may affect device reliability. 

Note 1.  All voltages are with respect to GND. 

#### **Recommended Operating Conditions** 

|**Parameter**|**Symbol**|**Min**|**Typ**|**Max**|**Units**|
|---|---|---|---|---|---|
|Operatingambient temperature|TA|-30||85|°C|
|Power supplyvoltage|VDD|2.4|3.0|3.6|V|
|Supply voltage accuracy, VDDtotal error<br>||-3||+3|%|
|includingtransients||||||
|LED supplyvoltage|VLEDA|3.0||4.5|V|



#### **Operating Characteristics, VDD = 3 V, TA = 25** ° **C (unless otherwise noted)** 

|**Parameter**|**Symbol**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|---|
|IDD supply current<sup>[1]</sup>|IDD||200|250|µA|Active ALS state<br>PON = AEN = 1, PEN = 0|
||||790|||Proximity, LDR pulse ON,<br>PPulse = 8  (ILDRnot included)|
||||790|||Gesture, LDR pulse ON,<br>GPulse = 8  (ILDRnot included)|
||||38|||Wait state<br>PON = 1, AEN = PEN = 0|
||||1.0|10.0||Sleepstate<sup>[2]</sup>|
|VOLINT, SDA output low voltage|VOL|0||0.4|V|3 mA sink current|
|ILEAKleakage current, SDA, SCL, INTpins|ILEAK|−5||5|µA||
|ILEAKleakage current, LDR P\pin|ILEAK|−10||10|µA||
|SCL, SDA input high voltage, VIH|VIH|1.26||VDD|V||
|SCL, SDA input low voltage, VIL|VIL|||0.54|V||



Notes 

1. Values are shown at the VDD pin and do not include current through the IR LED. 

2. Sleep state occurs when PON = 0 and I2C bus is idle. If Sleep state has been entered as the result of operational flow, SAI = 1, PON will be high. 

**Optical Characteristics, VDD = 3 V, TA = 25** ° **C, AGAIN = 16×, AEN = 1 (unless otherwise noted)** 

|**Parameter**|**Red Ch**|**annel**|**Green C**|**hannel**|**Blue C**|**hannel**|**Units**|**Test**|
|---|---|---|---|---|---|---|---|---|
||**Min**|**Max**|**Min**|**Max**|**Min**|**Max**||**Conditions**|
|**Irradiance**|0|15|10|42|57|100|%|λD= 465 nm<sup>[2]</sup>|
|**responsivity**<sup>**[1]**</sup>|4|25|54|85|10|45||λD= 525 nm<sup>[3]</sup>|
||64|120|0|14|3|29||λD= 625 nm<sup>[4]</sup>|



Notes: 

1.  The percentage shown represents the ratio of the respective red, green, or blue channel value to the clear channel value. 

2. The 465 nm input irradiance is supplied by an InGaN light-emitting diode with the following characteristics: dominant wavelength λD = 465 nm, spectral halfwidth Δλ½ = 22 nm. 

3.  The 525 nm input irradiance is supplied by an InGaN light-emitting diode with the following characteristics: dominant wavelength λD = 525 nm, spectral halfwidth Δλ½ = 35 nm. 

4.  The 625 nm input irradiance is supplied by a AlInGaP light-emitting diode with the following characteristics: dominant wavelength λD = 625 nm, spectral halfwidth Δλ½ = 15 nm. 

**RGBC Characteristics, VDD = 3 V, TA = 25** ° **C, AGAIN = 16×, AEN = 1 (unless otherwise noted)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|Dark ALS count value||0|3|counts|Ee= 0, AGAIN = 64×,<br>ATIME = 0×DB (100 ms)|
|ADC integration time stepsize||2.78||ms|ATIME = 0×FF|
|ADC number of integration steps|1||256|steps||
|Full scale ADC countsper step|||1025|counts||
|Full scale ADC count value|||65535|counts|ATIME = 0×C0 (175 ms)|
|Gain scaling, relative to 1× gain setting|3.6|4|4.4||4×|
||14.4|16|17.6||16×|
||57.6|64|70.4||64×|
|Clear channel irradiance responsivity|18.88|23.60|28.32|counts/(mW/cm2)|Neutral white LED,l= 560 nm|



#### **Proximity Characteristics, VDD = 3 V, TA = 25** ° **C, PEN = 1 (unless otherwise noted)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|ADC conversion time stepsize||696.6||µs||
|ADC number of integration steps||1||steps||
|Full scale ADC counts|||255|counts||
|LEDpulse count<sup>[1]</sup>|1||64|pulses||
|LED pulse width – LED on time<sup>[2]</sup>||4||µs|PPLEN = 0|
|||8|||PPLEN = 1|
|||16|||PPLEN = 2|
|||32|||PPLEN = 3|
|LED drive current<sup>[3]</sup>||100||mA|LDRIVE = 0|
|||50|||LDRIVE = 1|
|||25|||LDRIVE = 2|
|||12.5|||LDRIVE = 3|
|LED boost<sup>[3]</sup>||100||%|LED_BOOST = 0|
|||150|||LED_BOOST = 1|
|||200|||LED_BOOST = 2|
|||300|||LED_BOOST = 3|
|Proximity ADC count value,<br>no object<sup>[4]</sup>||10|25|counts|VLEDA= 3 V, LDRIVE = 100 mA,<br>PPULSE = 8, PGAIN = 4x, PPLEN =<br>8ms, LED_BOOST = 100%, open<br>view (no glass) and no reflective<br>object above the module.|



Table continued on next page... 

#### **Proximity Characteristics, VDD = 3 V, TA = 25** ° **C, PEN = 1 (unless otherwise noted) (continued)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|Proximity ADC count value,|96|120|144|counts|Reflecting object – 73 mm × 83 mm Kodak|
|100 mm distance object<sup>[5, 6]</sup>|||||90% grey card, 100 mm distance, VLEDA= 3 V,<br>LDRIVE = 100 mA, PPULSE = 8, PGAIN = 4x,|
||||||PPLEN = 8ms, LED_BOOST = 100%,<br>open view (noglass) above the module.|



Notes: 

1. This parameter is ensured by design and characterization and is not 100% tested. 8 pulses are the recommended driving conditions. For other driving conditions, contact Avago Field Sales. 

2. Value may be as much as 1.36μs longer than specified. 

3. Value is factory-adjusted to meet the Proximity count specification. Considerable variation (relative to the typical value) is possible after adjustment. LED BOOST increases current setting (as defined by LDRIVE or GLDRIVE). For example, if LDRIVE = 0 and LED BOOST = 100%, LDR current is 100mA. 

4. Proximity offset value varies with power supply characteristics and noise. 

5. ILEDA is factory calibrated to achieve this specification. Offset and crosstalk directly sum with this value and is system dependent. 

6. No glass or aperture above the module. Tested value is the average of 5 consecutive readings. 

**Gesture Characteristics, VDD = 3 V, TA = 25** ° **C, GEN = 1 (unless otherwise noted)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|ADC conversion time step size<sup>[1]</sup>||1.39||ms||
|LEDpulse count<sup>[2]</sup>|1||64|pulses||
|LED pulse width – LED on time<sup>[3]</sup>||4||ms|GPLEN = 0|
|||8|||GPLEN = 1|
|||12|||GPLEN = 2|
|||16|||GPLEN = 3|
|LED drive current<sup>[4]</sup>||100||mA|GLDRIVE = 0|
|||50|||GLDRIVE = 1|
|||25|||GLDRIVE = 2|
|||12.5|||GLDRIVE = 3|
|LED boost<sup>[4]</sup>||100||%|LED_BOOST = 0|
|||150|||LED_BOOST = 1|
|||200|||LED_BOOST = 2<sup>[5]</sup>|
|||300|||LED_BOOST = 3<sup>[5]</sup>|
|Gesture ADC count value,<br>no object<sup>[6]</sup>||10|25|counts|VLEDA= 3 V, GLDRIVE = 100 mA, GPULSE =<br>8, GGAIN = 4x, GPLEN = 8ms, LED_BOOST =<br>100%, open view (no glass) and no reflective<br>object above the module, sum of UP & DOWN<br>photodiodes.|
|Gesture ADC count value<sup>[7, 8]</sup>|96|120|144|counts|Reflecting object – 73 mm × 83 mm Kodak<br>90% grey card, 100 mm distance, VLEDA= 3 V,<br>GLDRIVE = 100 mA, GPULSE = 8, GGAIN = 4x,<br>GPLEN = 8ms, LED_BOOST = 100%,<br>open view (no glass) above the module,<br>sum of UP & DOWNphotodiodes.|
|Gesture wait stepsize||2.78||ms|GTIME = 0x01|



Notes: 

1. Each U/D or R/L pair requires a conversion time of 696.6 m s. For all four directions the conversion requires twice as much time. 

2. This parameter ensured by design and characterization and is not 100% tested. 8 pulses are the recommended driving conditions. For other driving conditions, contact Avago Field Sales. 

3. Value may be as much as 1.36 m s longer than specified. 

4. Value is factory-adjusted to meet the Gesture count specification. Considerable variation (relative to the typical value) is possible after adjustment. 

5. When operating at these LED drive conditions, it is recommended to separate the VDD and VLEDA supplies. 

6. Gesture offset value varies with power supply characteristics and noise. 

7. ILEDA is factory calibrated to achieve this specification. Offset and crosstalk directly sum with this value and is system dependent. 

8. No glass or aperture above the module. Tested value is the average of 5 consecutive readings. 

#### **IR LED Characteristics, VDD = 3 V, TA = 25** ° **C (unless otherwise noted)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|Peak Wavelength, λP||950||nm|IF= 20 mA|
|Spectrum Width, Half  Power, Δλ||30||nm|IF= 20 mA|
|Optical Rise Time, TR||20||ns|IF= 100 mA|
|Optical Fall Time, TF||20||ns|IF= 100 mA|



#### **Wait Characteristics, VDD = 3 V, TA = 25** ° **C, WEN = 1 (unless otherwise noted)** 

|**Parameter**|**Min**|**Typ**|**Max**|**Units**|**Test Conditions**|
|---|---|---|---|---|---|
|Wait StepSize||2.78||ms|WTIME= 0×FF|



#### **AC Electrical Characteristics, VDD = 3 V, TA = 25** ° **C (unless otherwise noted)**<sup>*****</sup> 

|**Parameter**|**Symbol**|**Min.**|**Max.**|**Unit**|
|---|---|---|---|---|
|Clock frequency(I<sup>2</sup>C-bus only)|fSCL|0|400|kHz|
|Bus free time between a STOP and START condition|tBUF|1.3|–|µs|
|Hold time (repeated) START condition. After this period, the first clock pulse<br>isgenerated|tHDSTA|0.6|–|µs|
|Set-uptime for a repeated START condition|tSU;STA|0.6|–|µs|
|Set-uptime for STOP condition|tSU;STO|0.6|–|µs|
|Data hold time|tHD;DAT|30|–|ns|
|Data set-uptime|tSU;DAT|100|–|ns|
|LOWperiod of the SCL clock|tLOW|1.3|–|µs|
|HIGHperiod of the SCL clock|tHIGH|0.6|–|µs|
|Clock/data fall time|tf|20|300|ns|
|Clock/data rise time|tr|20|300|ns|
|Inputpin capacitance|Ci|–|10|pF|



* Specified by design and characterization; not production tested. 



<!-- Start of picture text -->
t LOW tr tf<br>SCL VIH<br>VIL<br>tHD;STA tHIGH tSU;ST A<br>t BUF tHD;DAT tSU;DAT tSU;STO<br>SDA VIH<br>VIL<br>P S S P<br>Stop Start<br>Condition Condition<br><!-- End of picture text -->

**Figure 1. Timing Diagrams** 



<!-- Start of picture text -->
120%<br>Clear<br>C<br>100% Red<br>Green<br>Blue<br>80% G R Up/Down/Left/Right<br>60% U,D,L,R<br>40% B<br>20%<br>0%<br>300 400 500 600 700 800 900 1000 1100<br>Wavelength (nm)<br>Normalized Responsivity<br><!-- End of picture text -->

**Figure 2. Spectral Response** 



<!-- Start of picture text -->
1000<br>800<br>600<br>400<br>200<br>0<br>0 200 400 600 800 1000<br>Meter LUX<br>Figure 3c. ALS Sensor LUX vs Meter LUX using White Light<br>1.40<br>1.30<br>1.20<br>1.10<br>1.00<br>0.90<br>0.80<br>0.70<br>0.60<br>2.2 2.4 2.6 2.8 3 3.2 3.4 3.6 3.8 4<br>VDD (V)<br>Figure 4a. Normalized IDD vs. VDD<br>Avg Sensor LUX<br>Normalized IDD @ 3V 25°C<br><!-- End of picture text -->



<!-- Start of picture text -->
20000<br>16000<br>12000<br>8000<br>4000<br>0<br>0 4000 8000 12000 16000 20000<br>Meter LUX<br>Avg Sensor LUX<br><!-- End of picture text -->

**Figure 3a. ALS Sensor LUX vs Meter LUX using White Light** 



<!-- Start of picture text -->
5<br>4<br>3<br>2<br>1<br>0<br>0 1 2 3 4 5<br>Meter LUX<br>Figure 3b. ALS Sensor LUX vs Meter LUX using Incandescent Light<br>1.40<br>1.30<br>1.20<br>1.10<br>1.00<br>0.90<br>0.80<br>0.70<br>0.60<br>-60 -40 -20 0 20 40 60 80 100<br>Temperature (°C)<br>Avg Sensor LUX<br>Normalized IDD @ 3V<br><!-- End of picture text -->

**Figure 3b. ALS Sensor LUX vs Meter LUX using Incandescent Light** 

**Figure 4b. Normalized IDD vs. Temperature** 



<!-- Start of picture text -->
1.1<br>1<br>0.9<br>0.8<br>0.7<br>0.6<br>0.5<br>0.4<br>0.3<br>0.2<br>Half-power point<br>0.1<br>0<br>-50 -40 -30 -20 -10 0 10 20 30 40 50<br>Angle (Deg)<br>Normalized Responsitivity<br><!-- End of picture text -->

**Figure 5a. Normalized PD Responsitivity vs. Angular Displacement** 



<!-- Start of picture text -->
1.1<br>1<br>0.9<br>0.8<br>0.7<br>0.6<br>0.5<br>0.4<br>0.3<br>0.2<br>Half-power<br>0.1<br>point<br>0<br>-60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60<br>Angle (Deg)<br>Normalized Radiant Intensity<br><!-- End of picture text -->

**Figure 5b. Normalized LED Angular Emitting Profile** 

#### **I**<sup>**2**</sup> **C-bus Protocol** 

The I<sup>2</sup> C-bus standard provides for three types of bus transaction: read, write, and a combined protocol. During a write operation, the first byte written is a command byte followed by data. In a combined protocol, the first byte written is the command byte followed by reading a series of bytes. If a read command is issued, the register address from the previous command will be used for data access. Likewise, if the MSB of the command is not set, the device will write a series of bytes at the address stored in the last valid command with a register address. The command byte contains either control information or a 5-bit register address. The control commands can also be used to clear interrupts. 

Interface and control are accomplished through an I<sup>2</sup> C-bus serial compatible interface (standard or fast mode) to a set of registers that provide access to device control functions and output data. The devices support the 7-bit I<sup>2</sup> C-bus addressing protocol. 

The device supports a single slave address of 0×39 Hex using 7-bit addressing protocol. (Contact factory for other addressing options.) 



<!-- Start of picture text -->
A  Acknowledge (0)<br>byte contains either control information or a 5-bit register<br>N  Not Acknowledged (1)<br>address. The control commands can also be used to clear<br>P  Stop Condition<br>interrupts.<br>R  Read (1)<br>S  Start Condition The I 2 C-bus protocol was developed by Philips (now NXP).<br>Sr  Repeated Start Condition For a complete description of the I 2 C-bus protocol, please<br>W  Write (0) review the NXP I 2 C-bus design specification at http://<br>…  Continuation of protocol www.i2c−bus.org/references/.<br>Master-to-Slave<br>Slave-to-Master<br>1 7 1 1 8 1 8 1 1<br>S Slave Address W A Register Address A Data A ... P<br>I 2 C-bus Write Protocol<br>1 7 1 1 8 1 8 1 1<br>S Slave Address R A Data A Data A ... P<br>I 2 C-bus Read Protocol<br>1 7 1 1 8 1 1 7 1 1 8 1<br>S Slave Address W A Register Address A Sr Slave Address R A Data A<br>8 1 1<br>Data  A ... P<br><!-- End of picture text -->

The I<sup>2</sup> C-bus protocol was developed by Philips (now NXP). For a complete description of the I<sup>2</sup> C-bus protocol, please review the NXP I<sup>2</sup> C-bus design specification at http:// www.i2c−bus.org/references/. 

**I**<sup>**2**</sup> **C-bus Read Protocol - Combined Format** 

##### **I**<sup>**2**</sup> **C-bus Protocol** 

### **Detailed Description** 

Gesture detection, proximity detection, and RGBC color sense/ambient light sense functionality is controlled by a state machine, as depicted in Figure 12, which reconfigures on-chip analog resources when each functional engine is entered. Functional states/engines can be individually included or excluded from the progression of state machine flow. Each functional engine contains controls (E.g. Gain, ADC integration time, wait time, persistence, thresholds, etc.) that govern operation. Control of the Led Drive pin, LDR, is shared between Proximity and Gesture functionality. The color/ALS engine does not use the IR LED, but cross talk from IR LED emissions during an optical pattern transmission may affect results. 

The operational cycle of the device for Gesture/Proximity/ Color is as depicted in Figure 6 and Figure 7. 

Upon power-up, POR, the device initializes and immediately enters the low power SLEEP state. In this operational state the internal oscillator and other circuitry are not active, resulting in ultra-low power consumption. If I²C transaction occurs during this state, the oscillator and I²C core wakeup temporarily to service the communication. Once the Power ON bit, PON, is enabled, the internal oscillator and attendant circuitry are active, but power consumption remains low until one of the functional engine blocks are entered. The first time the SLEEP state is exited and any of the analog engines are enabled (PEN, GEN, AEN 

=1) an EXIT SLEEP pause occurs; followed by an immediate entry into the selected engine. If multiple engines are enabled, then the operational flow progresses in the following order: idle, proximity, gesture (if GMODE = 1), wait, color/ALS, and sleep (if SAI = 1 and INT pin is asserted). The wait operational state functions to reduce the power consumption and data collection rate. If wait is enabled, WEN=1, the delay is adjustable from 2.78ms to 8.54s, as set by the value in the WTIME register and WLONG control bit. 



<!-- Start of picture text -->
SLEEP<br>IDLE<br>COLOR<br>PROX<br>ALS<br>GESTURE WAIT<br>Gesture, Proximity<br>Color/ALS<br>State Machine<br><!-- End of picture text -->

**Figure 6. Simplified State Diagram** 



<!-- Start of picture text -->
INITILIZE<br>POR Operational States<br>(5.7 ms)<br>N<br>PEN ||<br>SLEEP PON == 1 ? GEN ||<br>Y AEN == 1 ?<br>Y<br>N Y<br>SAI == 1<br>&& INT  EXIT SLEEP<br>PIN == 0 ? (7 ms)<br>PON = 1<br>N PEN = 1<br>IDLE AEN = 1<br>GEN = 1<br>GMODE = 0 / 1<br>COLOR<br>PEN = 0 PEN = 1 PEN = 1<br>ENGINE<br>AEN = 1 AEN = 0 / 1 AEN = 0 / 1<br>Y GEN = 0 / 1 GEN = 0 / 1 GEN = 1<br>GMODE = 0  GMODE = 0  GMODE = 1<br>N WAIT PROXIMITY  GESTURE  GMODE is set by host<br>AEN == 1 ?<br>(0 – 8.5ms) ENGINE ENGINE<br>N GEN ==  Y<br>1 &&<br>GMODE<br>GMODE is set  == 1 ?<br>by Prox<br><!-- End of picture text -->

**Figure 7. Detailed State Diagram** 

### **Sleep After Interrupt Operation** 

After all the enabled engines/operational states have executed, causing a hardware interrupt, the state machine returns to either IDLE or SLEEP, as selected by the Sleep After Interrupt bit, SAI. SLEEP is entered when two conditions are met: SAI = 1, and the INT pin has been asserted. Entering SLEEP does not automatically change any of the register settings (E.g. PON bit is still high, but the normal operational state is over-ridden by SLEEP state). SLEEP state is terminated by an I²C clear of the INT pin or if SAI bit is cleared. 

### **Proximity Operation** 

The Proximity detection feature provides distance measurement by photodiode detection of reflected IR energy sourced by the integrated LED. The following registers and control bits govern proximity operation and the operational flow is depicted in Figure 8. 

**Table 1. Proximity Controls** 

|**Register/Bit**|**Address**|**Description**|
|---|---|---|
|ENABLE<PON>|0x80<0>|Power ON|
|ENABLE<PEN>|0x80<2>|ProximityEnable|
|ENABLE<PIEN>|0x80<5>|ProximityInterrupt Enable|
|PILT|0x89|Proximitylow threshold|
|PIHT|0x8B|Proximityhigh threshold|
|PERS<PPERS>|0x8C<7:4>|ProximityInterrupt Persistence|
|PPULSE<PPLEN>|0x8E<7:6>|ProximityPulse Length|
|PPULSE<PPULSE>|0x8E<5:0>|ProximityPulse Count|
|CONTROL<PGAIN>|0x8F<3:2>|ProximityGain Control|
|CONTROL<LDRIVE>|0x8F<7:6>|LED Drive Strength|
|CONFIG2<PSIEN>|0x90<7>|ProximitySaturation Interrupt Enable|
|CONFIG2<LEDBOOST>|0x90<5:4>|Proximity/Gesture LED Boost|
|STATUS<PGSAT>|0x93<6>|ProximitySaturation|
|STATUS<PINT>|0x93<5>|ProximityInterrupt|
|STATUS<PVALID>|0x93<1>|ProximityValid|
|PDATA|0x9C|ProximityData|
|POFFSET_UR|0x9D|ProximityOffset UP/RIGHT|
|POFFSET_DL|0x9E|ProximityOffset DOWN/LEFT|
|CONFIG3<PCMP>|0x9F<5>|ProximityGain Compensation Enable|
|CONFIG3<PMSK_U>|0x9F<3>|ProximityMask UP Enable|
|CONFIG3<PMSK_D>|0x9F<2>|ProximityMask DOWN Enable|
|CONFIG3<PMSK_L>|0x9F<1>|ProximityMask LEFT Enable|
|CONFIG3<PMSK_R>|0x9F<0>|ProximityMask RIGHT Enable|
|PICLEAR|0xE5|ProximityInterrupt Clear|
|AICLEAR|0xE7|All Non-Gesture Interrupt Clear|



## PROXIMITY ENGINE 



<!-- Start of picture text -->
ENTER<br>PROX<br>PEN = 1<br>COLLECT<br>PROX<br>DATA<br>DATA TO<br>PDATA<br>PVALID = 1<br>PILT <=  Y<br>PDATA<br><= PIHT<br>RESET<br>N PERSISTANCE<br>PERSISTANCE++<br>N<br>PERSISTANCE<br>>=<br>PPERS<br>Y<br>PINT = 1<br>N<br>PIEN ==1<br>?<br>Y<br>ASSERT INT PIN<br>EXIT<br>PVALID is automatically reset<br>whenever PDATA is read.<br>PINT must be manually reset<br>by a write-access to PICLEAR<br>or AICLEAR.<br><!-- End of picture text -->

**Figure 8. Detailed Proximity Diagram** 

Proximity results are affected by three fundamental factors: IR LED emission, IR reception, and environmental factors, including target distance and surface reflectivity. 

The IR reception signal path begins with IR detection from four [directional gesture] photodiodes and ends with the 8-bit proximity result in PDATA register. Signal from the photodiodes is combined, amplified, and offset adjusted to optimize performance. The same four photodiodes are used for gesture operation as well as proximity operation. Diodes are paired to form two signal paths: UP/RIGHT and DOWN/LEFT. Regardless of pairing, any of the photodiodes can be masked to exclude its contribution to the proximity result. Masking one of the paired diodes effectively reduces the signal by half and causes the full-scale result to be reduced from 255 to 127. To correct this reduction in full-scale, the proximity gain compensation bit, PCMP, can be set, returning F.S. to 255. Gain is adjustable from 1x to 8x using the PGAIN control bits. Offset correction or cross-talk compensation is accomplished by adjustment to the POFFSET_UR and POFSET_DL registers.The analog circuitry of the device applies the offset value as a subtraction to the signal accumulation; therefore a positive offset value has the effect of decreasing the results. 

Optically, the IR emission appears as a pulse train. The number of pulses is set by the PPULSE bits and the period of each pulse is adjustable using the PPLEN bits. The intensity of the IR emission is selectable using the LDRIVE control bits; corresponding to four, factory calibrated, current levels. If a higher intensity is required (E.g. longer detection distance or device placement beneath dark glass) then the LEDBOOST bit can be used to boost current up to an additional 300%. 

LED duty cycle and subsequent power consumption of the integrated IR LED can be calculated using the following table shown in Table 2, and equations. If proximity events are separated by a wait time, as set by AWAIT and WLONG, then the total LED off time must be increased by the wait time. 

**Table 2. Approximate Proximity Timing** 

||**tINIT**|**tLED ON**|**tACC**|**tCNVT**|
|---|---|---|---|---|
|**PPLEN**|**(μs)**|**(μs)**|**(μs)**|**(μs)**|
|4μs|40.8|5.4|28.6|796.6|
|8μs|44.9|9.5|36.73|796.6|
|16μs|53.0|17.7|53.1|796.6|
|32μs|69.4|34.0|85.7|796.6|



tPROX RESULT = tINIT + tCNVT + PPULSE x tACC 

tTOTAL LED ON = PPULSE x tLED ON tTOTAL LED OFF = tPROX RESULT – tTOTAL LED ON 

An Interrupt can be generated with each new proximity result or whenever proximity results exceed or fall below levels set in the PIHT and/or PILT threshold registers. To prevent premature/ false interrupts an interrupt persistence filter is also included; interrupts will only be asserted if the consecutive number of out-of-threshold results is equal or greater than the value set by PPERS. Each “inthreshold” proximity result, PDATA, will reset the persistence count. If the analog circuitry becomes saturated, the PGSAT bit will be asserted to indicate PDATA results 

may not be accurate. The PINT and PGSAT bits are always available for I²C polling, but PIEN bit must be set for PINT to assert a hardware interrupt on the INT pin. Similarly, saturation of the analog data converter can be detected by polling PGSAT bit; to enable this feature the PSIEN bit must be set. PVALID is cleared by reading PDATA. PGSAT, and PINT are cleared by “address accessing” (i.e. I²C transaction consisting of only two bytes: chip address, followed by a register address with R/W=1) PICLEAR or AICLEAR. 

**Table 3. Color / ALS Controls** 

|**Register/Bit**|**Address**|**Description**|
|---|---|---|
|ENABLE<PON>|0x80<1>|Power ON|
|ENABLE<AEN>|0x80<2>|ALS Enable|
|ENABLE<AIEN>|0x80<4>|ALS Interrupt Enable|
|ENABLE<WEN>|0x80<3>|Wait Enable|
|ATIME|0x82|ALS ADC Integration Time|
|WTIME|0x83|Wait Time|
|AILTL|0x84|ALS low threshold, lower byte|
|AILTH|0x85|ALS low threshold, upper byte|
|AIHTL|0x86|ALS high threshold, lower byte|
|AIHTH|0x87|ALS high threshold, upper byte|
|PERS<APERS>|0x8C<3:0>|ALS Interrupt Persistence|
|CONFIG1<WLONG>|0x8D<1>|Wait LongEnable|
|CONTROL<AGAIN>|0x8F<1:0>|ALS Gain Control|
|CONFIG2<CPSIEN>|0x90<6>|Clear diode Saturation Interrupt Enable|
|STATUS<CPSAT>|0x93<7>|Clear Diode Saturation|
|STATUS<AINT>|0x93<4>|ALS Interrupt|
|STATUS<AVALID>|0x93<0>|ALS Valid|
|CDATAL|0x94|Clear Data, Low byte|
|CDATAH|0x95|Clear Data, High byte|
|RDATAL|0x96|Red Data, Low byte|
|RDATAH|0x97|Red Data, High byte|
|GDATAL|0x98|Green Data, Low byte|
|GDATAH|0x99|Green Data, High byte|
|BDATAL|0x9A|Blue Data, Low byte|
|BDATAH|0x9B|Blue Data, High byte|
|CICLEAR|0xE5|Clear Channel Interrupt Clear|
|AICLEAR|0xE7|All Non-Gesture Interrupt Clear|



### **Color and Ambient Light Sense Operation** 

The Color and Ambient Light Sense detection functionality uses an array of color and IR filtered photodiodes to measure red, green, and blue content of light, as well as the non-color filtered clear channel. The following registers and control bits govern Color/ALS operation and the operational flow is depicted in Figure 9. 



<!-- Start of picture text -->
COLOR/ALS ENGINE<br>ENTER<br>COLOR<br>AEN = 1<br>COLLECT<br>COLOR<br>DATA<br>DATA TO<br>R,G,B,C DATA<br>AVALID = 1<br>AIL/H TL <=<br>CDATA<br><= A L/HTH<br>?<br>RESET<br>PERSISTANCE<br>PERSISTANCE++<br>PERSISTANCE  N<br>>=<br>APERS<br>Y<br>AINT = 1<br>AIEN ==1  N<br>?<br>Y<br>ASSERT INT PIN<br>EXIT<br>AVALID is automatically reset<br>whenever any of C,R,G,B-<br>DATA registers are read. AINT<br>and CPSAT are manually<br>reset by a write-access to<br>CICLEAR or AICLEAR.<br><!-- End of picture text -->

The Color/ALS reception signal path begins with filtered RGBC detection at the photodiodes and ends with the 16-bit results in the RGBC data registers. Signal from the photodiode array accumulates for a period of time set by the value in ATIME before the results are placed into the RGBCDATA registers. Gain is adjustable from 1x to 64x, and is determined by the setting of CONTROL<AGAIN>. Performance characteristics such as accuracy, resolution, conversion speed, and power consumption can be adjusted to meet the needs of the application. 

Before entering (re-entering) the Color/ALS engine, an adjustable, low power consumption, delay is entered. The wait time for this delay is selectable using the WEN, WTIME and WLONG control bits and ranges from 0 to 8.54s. During this period the internal oscillator is still running, but all other circuitry is deactivated. 

An interrupt can be generated whenever Clear Channel results exceed or fall below levels set in the AILTL/AIHTL and/or AILTH/AIHTH threshold registers. To prevent premature/false interrupts a persistence filter is also included; interrupts will only be asserted if the consecutive number of out-of-threshold results is equal or greater than the value set by APERS. Each “in-threshold” Clear channel result, CDATA, will reset the persistence count. If the analog circuitry becomes saturated, the ASAT bit will be asserted to indicate RGBCDATA results may not be accurate. The AINT and CPSAT bits are always available for I²C polling, but AIEN bit must be set for AINT to assert a hardware interrupt on the INT pin. Similarly, saturation of the analog data converter can be detected by polling CPSAT bit; to enable this feature the CPSIEN bit must be set. AVALID is cleared by reading RGBCDATA. ASAT, and AINT are cleared by “address  accessing” (i.e. I²C transaction consisting of only two bytes: chip address, followed by a register address with R/W=1) CICLEAR or AICLEAR. RGBC results can be used to calculate ambient light levels (i.e. Lux) and color temperature (i.e. Kelvin). 

**Figure 9. Color / ALS State Diagram** 

### **Gesture Operation** 

The Gesture detection feature provides motion detection by utilizing directionally sensitive photodiodes to sense reflected IR energy sourced by the integrated LED. The following registers and control bits govern gesture operation and the operational flow is depicted in Figure 10. 

**Table 4. Gesture Controls** 

|**Register/Bit**|**Address**|**Description**|
|---|---|---|
|ENABLE<PON>|0x80<0>|Power ON|
|ENABLE<GEN>|0x80<6>|Gesture Enable|
|GCONFIG4<GIEN>|0xAB<1>|Gesture Interrupt Enable|
|GPENTH|0xA0|Gesture ProximityEntryThreshold|
|GEXTH|0xA1|Gesture Exit Threshold|
|GCONFIG1<GFIFOTH>|0xA2<7:6>|Gesture FIFO Threshold|
|GCONFIG1<GEXMSK>|0xA2<5:2>|Gesture Exit Mask|
|GCONFIG1<GEXPERS>|0xA2<1:0>|Gesture Exit Persistence|
|GCONFIG2<GGAIN>|0xA3<6:5>|Gesture Gain Control|
|GCONFIG2<GLDRIVE>|0xA3<4:3>|Gesture LED Drive Strength|
|GCONFIG2<GWTIME>|0xA3<2:0>|Gesture Wait Time|
|STATUS<PGSAT>|0x93<6>|Gesture Saturation|
|CONFIG2<LEDBOOST>|0x90<5:4>|Gesture/ProximityLED Boost|
|GOFFSET_U|0xA4|Gesture Offset, UP|
|GOFFSET_D|0xA5|Gesture Offset, DOWN|
|GOFFSET_L|0xA7|Gesture Offset, LEFT|
|GOFFSET_R|0xA9|Gesture Offset, RIGHT|
|GPULSE<GPULSE>|0xA6<5:0>|Pulse Count|
|GPULSE<GPLEN>|0xA6<7:6>|Gesture Pulse Length|
|GCONFIG3<GDIMS>|0xAA<1:0>|Gesture Dimension Select|
|GCONFIG4<GIEN>|0xAB<1>|Gesture Interrupt Enable|
|GCONFIG4<GMODE>|0xAB<0>|Gesture Mode|
|GFLVL|0xAE|Gesture FIFO Level|
|GSTATUS<GFOV>|0xAF<1>|Gesture FIFO Overflow|
|GSTATUS<GVALID>|0xAF<0>|Gesture Valid|
|GFIFO_U|0xFC|Gesture FIFO Data, UP|
|GFIFO_D|0xFD|Gesture FIFO Data, DOWN|
|GFIFO_L|0xFE|Gesture FIFO Data, LEFT|
|GFIFO_R|0xFF|Gesture FIFO Data, RIGHT|
|CONFIG1<LOWPOW>|0x8D|Low Power Clock Mode|





<!-- Start of picture text -->
ENTER<br>GESTURE GESTURE ENGINE<br>GMODE = 1 Has FIFO<br>GVALID = 0/1  overflowed?<br>GINT=0/1<br>Y<br>GFLVL s  == 32<br>GFOV = 1<br>?<br>N<br>GDIMS != 10 N<br>DATA TO FIFO<br>Y<br>GFLVL s ++ Y<br>PHOTODIODECOLLECT  U/D In FIFO to assert Enough data GEXTH? s  == 0<br>DATA interrupt? GFLVL s  >= Remain in gesture mode indefinatly?<br>GFIFOTH s N<br>N<br>?<br>Y<br>N UNM ASKED N<br>GDIMS != 01 GVALID = 1 GDATA <=<br>GINT = 1 GEXTH s<br>Is GDATA<br>indicating<br>Y GIEN ==1 N has finished?“hand  wave” Y P ERSISTANCERESET<br>COLLECT  L/R ? PERSISTANCE++<br>PHOTODIODE<br>DATA Y<br>C<br>ASSERT INT PIN<br>Have enough “hand wave<br>over” datasets occurred<br>DATA AQUISITION FIFO & INTERRUPTS consecutively to exit<br>Gesture?<br>N PERSISTANCE<br>N >=<br>GEXPERS s<br>G W TIME > 0 GMODE == 0<br>WA IT<br>? ?<br>Y N<br>Y<br>WAIT Has GMODEbeen Y GMODE=0<br>cleared by host?<br>LOOP CONTROL<br>N<br>N GFLVL s > = GVALID == 1 *Special state to clear FIFO in the event of gesture entry<br>GFIFOTH s ? followed by rapid exit. This<br>? RESET FIFO condition results in to few<br>FIFO datasets to assert GINT.<br>Y Conditions: (Orphanded data) Y This state prevents the<br>1. Gesture entry (GMODE=1) condition where “old” data<br>GI N T = 1 2. GFLVL < GFIFOTH (GINT always 0)3. Gesture exit (GMODE = 0) exists in FIFO that is not part of current gesture entry.<br>GINT = 1<br>G VAL ID = 1<br>N<br>GIEN ==1<br>Y ?<br>N<br>GFLVL s  ==0 GINT = 0<br>? Y<br>ASSERT INT PIN<br>Y<br>GMODE ==1<br>?<br>GMODE = 0<br>GVALID = 0 N GVALID = 0/1GFLVL >= 0GINT = 1 GESTUREEXIT GMODE = 0, but GDATA is stillavailable after exit from gesture*If gesture motion has ended,<br>engine.<br>ee<br>sh<br>a t a<br>D<br>y<br>r<br>a<br>mi<br>eli<br>r<br>P<br><!-- End of picture text -->

**Figure 10. Detailed Gesture Diagram** 

Gesture results are affected by three fundamental factors: IR LED emission, IR reception, and environmental factors, including motion. 

During operation, the Gesture engine is entered when its enable bit, GEN, and the operating mode bit, GMODE, are both set. GMODE can be set/reset manually, via I²C, or becomes set when proximity results, PDATA, is greater or equal to the gesture proximity entry threshold, GPENTH. Exit of the gesture engine will not occur until GMODE is reset to zero. During normal operation, GMODE is reset when all 4-bytes of a gesture dataset fall below the exit threshold, GEXTH, for GEXPERS times. This exit condition is also influenced by the gesture exit mask, GEXMSK, which includes all non-masked datum (i.e. singular 1-byte U, D, L, R points). To prevent premature exit, a persistence filter is also included; exit will only occur if a consecutive number of below-threshold results is greater or equal to the persistence value, GEXPERS. Each dataset result that is above-threshold will reset the persistence count. False or incomplete gestures (engine entry and exit without GVALID transitioning high) will not generate a gesture interrupt, GINT, and FIFO data will automatically be purged. 

Once in operating inside the gesture engine, the IR reception signal path begins with IR detection at the photodiodes and ends with the four, 8-bit gesture results corresponding to accumulated signal strength on each diode. Signal from the four photodiodes is amplified, and offset adjusted to optimize performance. Photodiodes are paired to form two signal paths: UP/DOWN and LEFT/RIGHT. Photodiode pairs can be masked to exclude its results from the gesture FIFO data. For example, if only UP-DOWN motions detection is required the gesture dimension control bits, GDIMS, may be set to 0x01. FIFO data will be zero for RIGHT/LEFT results and accumulation/ADC integration time will be approximately halved. Gain is adjustable from 

1x to 8x using the GGAIN control bits. Offset correction is accomplished by individual adjustment to GOFFSET_U, GOFFSET_D, GOFFSET_L, GOFFSET_R registers to improve cross-talk performance. The analog circuitry of the device applies offset values as a subtraction to the signal accumulation; therefore a positive offset value has the effect of decreasing the results. 

Optically, the IR emission appears as a pulse train. The number of pulses is set by the GPULSE bits and the period of each pulse is adjustable using the GPLEN bits. Pulse train repetition (i.e. the circular flow of operation inside the gesture state machine) can be delayed by setting a non-zero value in the gesture wait time bits, GWTIME. The inclusion of a wait state reduces the both the power consumption and the data rate. 

The intensity of the IR emission is selectable using the GLDRIVE control bits; corresponding to four, factory calibrated, current levels. If a higher intensity is required (E.g. longer detection distance or device placement beneath dark glass) then the LEDBOOST bit can be used to boost current up to an additional 300%. 

The current consumption of the integrated IR LED is shown in Table 5. (Three examples at various LED drive settings) 

**Table 5. Simplified Power Calculation** 

||**Case 1**|**Case 2**|**Case 3**|
|---|---|---|---|
|**ILED (mA)**|100|150|300|
|**GPULSE (no ofpulses)**|8|8|8|
|**GPLEN (us)**|16|16|32|
|**GWTIME (No of wait state)**|2|2|1|
|**Total Current  (mA)**|3.76|5.49|16.14|



An interrupt is generated based on the number of gesture “datasets” results placed in the FIFO. A dataset is defined as 4-byte directional data corresponding to U-D-L-R.The FIFO can buffer up to 32 datasets before it overflows. If the FIFO overflows (host did not read quickly enough) then the most recent data will be lost. If the FIFO level, GFLVL, becomes greater or equal to the threshold value set by GFIFOTH, then the GVALID bit is set, indicating valid data is available; the gesture interrupt bit, GINT, is asserted, and if GIEN bit is set a hardware interrupt on the INT pin will also assert. Before exit of gesture engine, one final interrupt will always occur if GVALID is asserted, signaling data remains in the FIFO. Gesture Interrupts flags: GINT, GVALID, and GFLVL are cleared by emptying e. all data has been read). 

The correlation of motion to FIFO data and direction characteristics) is not obvious at first glance. As depicted in Figure 12, the four directional sensors are placed in an orthogonal pattern optically lensed aperture. Diodes are designated as: U, D, L, R; the 8-bit results corresponding to each diode is available at the following sequential FIFO locations: 0xFC, 0xFD, 0xFE, and 0xFF. 

Ideally, gesture detection works by capturing and comparing the amplitude and phase difference between directional sensor results. The directional sensors are arranged such that the diode opposite to the directional motion receives a larger portion of the reflected IR signal upon entry, then a smaller portion upon exit. In the example illustration, a downward or rightward motion of a target is illustrated per the respective arrows in Figure 11. 

#### **Directional Orientation** 



<!-- Start of picture text -->
Downward Ideal response U<br>motion L R<br>D<br>Time<br>Up 0xFC Down 0xFD Left 0xFE Right 0xFF LED<br>Rightward Ideal response<br>motion<br>Time<br>Up 0xFC Down 0xFD Left 0xFE Right 0xFF<br>Counts<br>Counts<br><!-- End of picture text -->

**Figure 11. Directional Orientation** 

### **Optical and Mechanical Design Consideration** 

#### **Optical Transmittance of Window Material** 

Windows with an IR transmittance of at least 80% (measured at 950nm) are recommended for use with the APDS9960.  Note that for aesthetic reasons, the window’s material could be tinted or coated with a dark ink. For example, a 20% (measured at 550nm) visible transmittance window with 80% IR transmittance can be used. Such a coating would have transmittance spectral response with low transmittance within the visible range and a high transmittance in the infrared range. This low to high transmittance transition wavelength should be shorter than 650nm to minimize crosstalk. 

Examples of recommended window material part numbers are shown in the table below. 

#### **Crosstalk and Window Air Gap** 

Crosstalk is PS or Gesture output caused by unwanted LED IR rays reflection without any object present. To control crosstalk when operating the sensor in gesture mode, we recommend that a rubber isolating barrier be fitted over the sensor. A possible design is shown in Figure 12. 

The rubber consists of two cylindrical openings, one for the LED and the other for the Photodetector. The window thickness should not be more than 1mm. When assembled the rubber barrier should form a good optical seal to the bottom of the window. 

#### **Recommended dimensions of the barrier are:** 

||**PD Opening**|**LED Opening**|
|---|---|---|
|**Air Gap**|**Diameter**|**Diameter**|
|1mm|2mm|1.5mm|



**Table 1. Recommended Plastic Materials** 

|**Material number**|**Visible light**<br>**transmission**|**Refractive index**|
|---|---|---|
|Makrolon LQ2647|87%|1.587|
|Makrolon LQ3147|87%|1.587|
|Makrolon LQ3187|85%|1.587|
|Lexan OQ92S|88 - 90%|-|
|Lexan OQ4120R|88 - 90%|1.586|
|Lexan OQ4320R|88 - 90%|1.586|



Residual crosstalk of the Up, Down, Left and Right Gesture output may be reduced by writing to the individual GOFFSET registers. Such calibration is necessary to ensure good gesture sensing performance. 



<!-- Start of picture text -->
Window<br>Thickness<br>LED Opening<br>PD Opening Diameter Diameter<br>Optical<br>Air Gap or Barrier Height Barrier<br>i<br>Figure 12. Rubber Barrier<br>300<br>90% Kodak Card<br>250 18% Kodak Card<br>Opteka Black Card<br>200 ‘ \<br>\. \<br>\ \<br>150 \ x<br>100 N sa < N S<br>x re ~<br>50<br>0<br>0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>PS Count PS Count<br><!-- End of picture text -->



<!-- Start of picture text -->
300<br>4P<br>250 8P<br>n<br>200<br>.<br>A<br>150 .<br>\,<br>100 i<br>.<br>i<br>50<br>0<br>0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>Distance (cm)<br>PS Count<br><!-- End of picture text -->



<!-- Start of picture text -->
Distance (cm)<br><!-- End of picture text -->

**Figure 13a. PS Output vs. Distance at LDRIVE = 100 mA, PGAIN = 4x, PPLEN = 8** m **s, LED_BOOST = 100% with various pulses. No glass in front of the module** 

**Figure 13a. PS Output vs. Distance at LDRIVE = 100 mA, PPULSE = 8, PGAIN = 4x, PPLEN = 8** m **s, LED_BOOST = 100% with various objects. No glass in front of the module** 

### **Register Set** 

The APDS-9960 is controlled and monitored by data registers and a command register accessed through the serial interface. These registers provide for a variety of control functions and can be read to determine results of the ADC conversions. 

|**Address**|**Register Name**|**Type**|**Register Function**|**Reset Value**|
|---|---|---|---|---|
|0x00 –|RAM|R/W|RAM|0x00|
|0x7F|||||
|0x80|ENABLE|R/W|Enable states and interrupts|0x00|
|0x81|ATIME|R/W|ADC integration time|0xFF|
|0x83|WTIME|R/W|Wait time(non-gesture)|0xFF|
|0x84|AILTL|R/W|ALS interrupt low threshold low byte|--|
|0x85|AILTH|R/W|ALS interrupt low threshold high byte|--|
|0x86|AIHTL|R/W|ALS interrupt high threshold low byte|0x00|
|0x87|AIHTH|R/W|ALS interrupt high threshold high byte|0x00|
|0x89|PILT|R/W|Proximityinterrupt low threshold|0x00|
|0x8B|PIHT|R/W|Proximityinterrupt high threshold|0x00|
|0x8C|PERS|R/W|Interruptpersistence filters(non-gesture)|0x00|
|0x8D|CONFIG1|R/W|i<br>Configuration register one|0x40|
|0x8E|PPULSE|R/W|Proximity pulse count and length|0x40|
|0x8F|CONTROL|R/W|Gain control<br>i|0x00|
|0x90|CONFIG2|R/W|Configuration register two|0x01|
|0x92|ID|R|Device ID|ID|
|0x93|STATUS|R|Device status|0x00|
|0x94|CDATAL|R|Low byte of clear channel data|0x00|
|0x95|CDATAH|R|High byte of clear channel data|0x00|
|0x96|RDATAL|R|Low byte of red channel data|0x00|
|0x97|RDATAH|R|High byte of red channel data|0x00|
|0x98|GDATAL|R|Low byte ofgreen channel data|0x00|
|0x99|GDATAH|R|High byte ofgreen channel data|0x00|
|0x9A|BDATAL|R|Low byte of blue channel data|0x00|
|0x9B|BDATAH|R|High byte of blue channel data|0x00|
|0x9C|PDATA|R|Proximitydata<br>f|0x00|
|0x9D|POFFSET_UR|R/W|Proximityoffset for UP and RIGHTphotodiodes<br>f|0x00|
|0x9E|POFFSET_DL|R/W|Proximityoffset for DOWN and LEFTphotodiodes|0x00|
|0x9F|CONFIG3|R/W|Configuration register three|0x00|
|0xA0|GPENTH|R/W|Gestureproximityenter threshold|0x00|
|0xA1|GEXTH|R/W|Gesture exit threshold|0x00|
|0xA2|GCONF1|R/W|Gesture configuration one|0x00|
|0xA3|GCONF2|R/W|Gesture configuration two<br>f|0x00|
|0xA4|GOFFSET_U|R/W|Gesture UP offset register<br>f|0x00|
|0xA5|GOFFSET_D|R/W|Gesture DOWN offset register|0x00|
|0xA7|GOFFSET_L|R/W|Gesture LEFT offset register<br>f|0x00|
|0xA9|GOFFSET_R|R/W|Gesture RIGHT offset register|0x00|
|0xA6|GPULSE|R/W|Gesturepulse count and length<br>i|0x40|
|0xAA|GCONF3|R/W|Gesture configuration three<br>i|0x00|
|0xAB|GCONF4|R/W|Gesture configuration four|0x00|
|0xAE|GFLVL|R|Gesture FIFO level|0x00|
|0xAF|GSTATUS|R|Gesture status|0x00|
|0xE4(1)|IFORCE|W|Force interrupt|0x00|
|0xE5(1)|PICLEAR|W|Proximityinterrupt clear|0x00|
|0xE6(1)|CICLEAR|W|ALS clear channel interrupt clear|0x00|
|0xE7(1)|AICLEAR|W|All non-gesture interrupts clear|0x00|
|0xFC|GFIFO_U|R|Gesture FIFO UP value|0x00|
|0xFD|GFIFO_D|R|Gesture FIFO DOWN value|0x00|
|0xFE|GFIFO_L|R|Gesture FIFO LEFT value|0x00|
|0xFF|GFIFO_R|R|Gesture FIFO RIGHT value|0x00|



Note 

1. Interrupt clear and force registers require a special I2C “address accessing” transaction. Please refer to the Register Description section for details. 

### **Enable Register (0x80)** 

The ENABLE register is used to power the device on/off, enable functions and interrupts. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|Reserved|7|Reserved. Write as 0.|
|GEN|6|Gesture Enable.  When asserted, the gesture state machine can be activated.<br>Activation is subject to the states of PEN and GMODE bits.|
|PIEN|5|Proximity Interrupt Enable. When asserted, it permits proximity interrupts to be generated, subject to the<br>persistence filter settings.|
|AIEN|4|ALS Interrupt Enable. When asserted, it permits ALS interrupts to be generated, subject to the persistence<br>filter settings.|
|WEN|3|Wait Enable. This bit activates the wait feature. Writing a one activates the wait timer. Writing a zero<br>disables the wait timer.|
|PEN|2|Proximity Detect Enable. This field activates the proximity detection.<br>Writinga one activates theproximity. Writinga zero disables theproximity.|
|AEN|1|ALS Enable. This field activates ALS function. Writing a one activates the ALS. Writing a zero disables the<br>ALS.|
|PON|0|Power ON. This field activates the internal oscillator to permit the timers and ADC channels to operate.<br>Writing a one activates the oscillator.  Writing a zero disables the oscillator and puts the device into a low<br>power sleep mode. During reads and writes over the I2C interface, this bit is temporarily overridden and<br>the oscillator is enabled, independent of the state of PON.|



Note: Before enabling Gesture, Proximity, or ALS, all of the bits associated with control of the desired function must be set. Changing control register values while operating may result in invalid results. 

### **ADC Integration Time Register (0x81)** 

The ATIME register controls the internal integration time of ALS/Color analog to digital converters. Upon power up, the ADC integration time register is set to 0xFF. 

The maximum count (or saturation) value can be calculated based upon the integration time and the size of the count register (i.e. 16 bits). For ALS/Color, the maximum count will be the lesser of either: 

- 65535 (based on the 16 bit register size) or 

- The result of equation: CountMAX = 1025 x CYCLES 

|**Field**|**Bits**|**Description**||||
|---|---|---|---|---|---|
|ATIME|7:0|**FIELD VALUE**|**CYCLES**|**TIME**|**MAX COUNT**|
|||0|256|712 ms|65535|
|||182|72|200 ms|65535|
|||= 256 – TIME / 2.78 ms|…|…|…|
|||219|37|103 ms|37889|
|||246|10|27.8 ms|10241|
|||255|1|2.78 ms|1025|



Note:  The ATIME register is only applicable to ALS/Color engine (16-bit data). The integration time for the 8-bit Proximity/Gesture engine, is a factor of four less than the nominal time (2.78ms), resulting in a fixed time of 0.696ms. 

### **Wait Time Register (0x83)** 

The WTIME controls the amount of time in a low power mode between Proximity and/or ALS cycles. It is set 2.78ms increments unless the WLONG bit is asserted in which case the wait times are 12× longer. WTIME is programmed as a 2’s complement number. Upon power up, the wait time register is set to 0xFF. 

|**Field**|**Bits**|**Description**||||
|---|---|---|---|---|---|
|WTIME|7:0|**FIELD VALUE**|**WAIT TIME**|**TIME (WLONG = 0)**|**TIME (WLONG = 1)**|
|||0|256|712 ms|8.54 s|
|||= 256 – TIME / 2.78 ms|…|…||
|||171|85|236 ms|2.84 s|
|||255|1|2.78 ms|0.03 s|



Notes: 

1. The wait time register should be configured before AEN and/or PEN is asserted. 

2. During any Proximity and/or ALS cycle, the wait state, depicted in the functional block diagram, is entered. For example, Prox only, Prox and ALS, or ALS only cycles always enter the WAIT state and are separated by the time defined by WTIME. 

### **ALS Interrupt Threshold Register (0x84 – 0x87)** 

ALS level detection uses data generated by the Clear Channel. The ALS Interrupt Threshold registers provide 16-bit values to be used as the high and low thresholds for comparison to the 16-bit CDATA values. If AIEN is enabled and CDATA is greater than AILTH/AIHTH or less than AILTL/AIHTL for the number of consecutive samples specified in APERS an interrupt is asserted on the interrupt pin. 

|**Field**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|AILTL|0x84|7:0|This registerprovides the low byte of the low interrupt threshold.|
|AILTH|0x85|7:0|This registerprovides the high byte of the low interrupt threshold.|
|AIHTL|0x86|7:0|This registerprovides the low byte of the high interrupt threshold.|
|AIHTH|0x87|7:0|This registerprovides the high byte of the high interrupt threshold.|



### **Proximity Interrupt Threshold Register (0x89/0x8B)** 

The Proximity Interrupt Threshold Registers set the high and low trigger points for the comparison function which generates an interrupt. If PDATA, the value generated by proximity channel, crosses below the lower threshold specified, or above the higher threshold, an interrupt may be signaled to the host processor. Interrupt generation is subject to the value set in persistence (PERS). 

|**Field**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|PILT|0x89|7:0|This registerprovides the low interrupt threshold.|
|PIHT|0x8B|7:0|This registerprovides the high interrupt threshold.|



### **Persistence Register (0x8C)** 

The Interrupt Persistence Register sets a value which is compared with the accumulated amount of ALS or Proximity cycles in which results were outside threshold values. Any Proximity or ALS result that is inside threshold values resets the count. 

Separate counters are provided for proximity and ALS persistence detection. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|PPERS|7:4|ProximityInte|rrupt Persistence. Controls rate ofproximityinterrupt to the hostprocessor.|
|||**FIELD VALUE**|**INTERRUPT GENERATED WHEN…**|
|||0|Every proximitycycle|
|||1|Any proximityvalue outside of threshold range|
|||2|2 consecutiveproximityvalues out of range|
|||3|3 consecutiveproximityvalues out of range|
|||…|…|
|||15|15 consecutiveproximityvalues out of range|
|APERS|3:0|ALS Interrupt|Persistence. Controls rate of Clear channel interrupt to the hostprocessor.|
|||**FIELD VALUE**|**INTERRUPT GENERATED WHEN…**|
|||0|EveryALS cycle|
|||1|AnyALS value outside of threshold range|
|||2|2 consecutiveproximityvalues out of range|
|||3|3 consecutiveproximityvalues out of range|
|||4|5 …|
|||5|10 …|
|||6|15 …|
|||7|20 …|
|||8|25 …|
|||9|30 …|
|||10|35 …|
|||11|40 …|
|||12|45 …|
|||13|50 …|
|||14|55 …|
|||15|60 consecutive ALS values out of range|



### **Configuration Register One (0x8D)** 

The CONFIG1 register sets the wait long time. The register is set to 0x40 at power up. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|Reserved|7|Reserved. Write as 0.|
|Reserved|6|Reserved. Write as 1.|
|Reserved|5|Reserved. Write as 1.|
|Reserved|4|Reserved. Write as 0.|
|Reserved|3|Reserved. Write as 0.|
|Reserved|2|Reserved. Write as 0.|
|WLONG|1|Wait Long. When asserted, the wait cycle is increased by a factor 12x from that programmed in<br>the WTIME register.|
|Reserved|0|Reserved. Write as 0.|



Notes: 

1. Bit 6 is reserved, and is automatically set to 1 at POR. 

2. Bit 5 is reserved, and is automatically set to 1 at POR. If this bit is not set, power consumption will increase during wait states. 

### **Proximity Pulse Count Register (0x8E)** 

The Proximity Pulse Count Register sets Pulse Width Modified current during a Proximity Pulse. The proximity pulse count register bits set the number of pulses to be output on the LDR pin. The Proximity Length register bits set the amount of time the LDR pin is sinking current during a proximity pulse. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|PPLEN|7:6|ProximityPul|se Length. Sets the LED-ONpulse width duringaproximityLDRpulse.|
|||**FIELD VALUE**|**PULSE LENGTH**|
|||0|4ms|
|||1|8ms (default)|
|||2|16ms|
|||3|32ms|
|PPULSE|5:0|Proximity Pul  i<br>Number ofpu|se Count. Specifies the number of proximity pulses to be generated on LDR.<br>lses is set byPPULSE valueplus 1.|
|||**FIELD VALUE**|**NUMBER OF PULSES**|
|||0|1|
|||1|2|
|||2|3|
|||…|…|
|||63|64|



Notes: 

1. The time described by PPLEN is the actual signal integration time. The LED will be activated slightly longer (typically 1.36 μs) than the integration time. 

2. The Proximity Pulse Count Register resets to 0x40 

### **Control Register One (0x8F)** 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|LDRIVE|7:6|LED Drive Str|ength.|
|||**FIELD VALUE**|**LED CURRENT**|
|||0|100 mA|
|||1|50 mA|
|||2|25 mA|
|||3|12.5 mA|
|Reserved|5|Reserved. Wri|te as 0.|
|Reserved|4|Reserved. Wri|te as 0.|
|PGAIN|3:2|ProximityGai|n Control.|
|||**FIELD VALUE**|**GAIN VALUE**|
|||0|1x|
|||1|2x|
|||2|4x|
|||3|8x|
|AGAIN|1:0|ALS and Colo|r Gain Control.|
|||**FIELD VALUE**|**GAIN VALUE**|
|||0|1x|
|||1|4x|
|||2|16x|
|||3|64x|



### **Configuration Register Two (0x90)** 

The Configuration Register Two independently enables or disables the saturation interrupts for Proximity and Clear channel. Saturation Interrupts are cleared by accessing the Clear Interrupt registers at 0xE5, 0xE6 and 0xE7. The LED_ BOOST bits allow the LDR pin to sink more current above the maximum setting by LDRIVE and GLDRIVE. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|PSIEN|7|Proximity Saturation Interrupt Enable.<br>0 = Proximity saturation interrupt disabled<br>1 = Proximitysaturation interrupt enabled|
|CPSIEN|6|Clear Photodiode Saturation Interrupt Enable.<br>0 = ALS Saturation Interrupt disabled<br>1 = ALS Saturation Interrupt enabled|
|LED_BOOST|5:4|Additional LDR current during proximity and gesture LED pulses. Current value, set by LDRIVE,<br>is increased bythepercentage of LED_BOOST.|
|||**FIELD VALUE**<br>**LED BOOST CURRENT**|
|||0<br>100%|
|||1<br>150%|
|||2<br>200%|
|||3<br>300%|
|RESERVED|3:1|Reserved. Write as 0.|
|RESERVED|0|Reserved. Write as 1. Set high bydefault duringPOR.|



Note: A LED_BOOST value of 0 results in 100% of the current as set by LDRIVE (no additional current). 

### **ID Register (0x92)** 

The read-only ID Register provides the device identification. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|ID|7:0|Part number identification.|
|||0xAB = APDS-9960|



### **Status Register (0x93)** 

The read-only Status Register provides the status of the device. The register is set to 0x04 at power-up. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|CPSAT|7|Clear Photodiode Saturation. When asserted, the analog sensor was at the upper end of its<br>dynamic range. The bit can be de-asserted by sending a Clear channel interrupt command<br>(0xE6 CICLEAR) or bydisablingthe ADC (AEN=0). This bit triggers an interrupt if CPSIEN is set.|
|PGSAT|6|Indicates that an analog saturation event occurred during a previous proximity or gesture<br>cycle. Once set, this bit remains set until cleared by clear proximity interrupt special function<br>command (0xE5 PICLEAR) or by disabling Prox (PEN=0). This bit triggers an interrupt if PSIEN<br>is set.|
|PINT|5|ProximityInterrupt. This bit triggers an interrupt if PIEN in ENABLE is set.|
|AINT|4|ALS Interrupt. This bit triggers an interrupt if AIEN in ENABLE is set.|
|RESERVED|3|Do not care.|
|GINT|2|Gesture Interrupt. GINT is asserted when GFVLV becomes greater than GFIFOTH or if GVALID<br>has become asserted when GMODE transitioned to zero. The bit is reset when FIFO is<br>completelyemptied (read).|
|PVALID|1|Proximity Valid. Indicates that a proximity cycle has completed since PEN was asserted or since<br>PDATA was last read. A read of PDATA automaticallyclears PVALID.|
|AVALID|0|ALS Valid. Indicates that an ALS cycle has completed since AEN was asserted or since a read<br>from anyof the ALS/Color data registers.|



### **RGBC Data Register (0x94 – 0x9B)** 

Red, green, blue, and clear data is stored as 16-bit values. The read sequence must read byte pairs (low followed by high) starting on an even address boundary (0x94, 0x96, 0x98, or 0x9A) inside the RGBC Data Register block. When the lower byte register is read, the upper eight bits are stored into a shadow register, which is read by a subsequent read to the upper byte. The upper register will read the correct value even if additional ADC integration cycles end between the reading of the lower and upper registers. 

|**Field**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|CDATAL|0x94|7:0|Low Byte of clear channel data.|
|CDATAH|0x95|7:0|High Byte of clear channel data.|
|RDATAL|0x96|7:0|Low Byte of red channel data.|
|RDATAH|0x97|7:0|High Byte of red channel data.|
|GDATAL|0x98|7:0|Low Byte ofgreen channel data.|
|GDATAH|0x99|7:0|High Byte ofgreen channel data.|
|BDATAL|0x9A|7:0|Low Byte of blue channel data.|
|BDATAH|0x9B|7:0|High Byte of blue channel data.|



Note: When reading register contents, a read of the lower byte data automatically latches the corresponding higher byte data (16 bit latch). This feature guarantees that the high byte value has not been updated by the ADC between I2C reads. In addition, reading CDATAL register not only latches CDATAH but also latches all eight RGBC register simultaneously (64 bit latch). 

### **Proximity Data Register (0x9C)** 

Proximity data is stored as an 8-bit value. 

|**Field**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|PDATA|0x9C|7:0|Proximitydata.|



### **Proximity Offset UP / RIGHT Register (0x9D)** 

In proximity mode, the UP and RIGHT photodiodes are connected forming a diode pair. The POFFSET_UR is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|POFFSET_UR<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Proximity Offset DOWN / LEFT Register (0x9E)** 

In Proximity mode, the DOWN and LEFT photodiodes are connected forming a diode pair. The POFFSET_DL is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|POFFSET_DL<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Configuration Three Register (0x9F)** 

The CONFIG3 register is used to select which photodiodes are used for proximity. Two photodiodes are paired to provide signal. In proximity mode, UP and RIGHT photodiodes are connected forming a diode pair; similarly the DOWN and LEFT photodiodes form a diode pair. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|RESERVED|7:6|Reserved. Write as 0.|
|PCMP|5|Proximity Gain Compensation Enable. This bit provides gain compensation when proximity<br>photodiode signal is reduced as a result of sensor masking. If only one diode of the diode pair<br>is contributing, then only half of the signal is available at the ADC; this results in a maximum<br>ADC value of 127. Enabling PCMP enables an additional gain of 2X, resulting in a maximum<br>ADC value of 255.|
|||**PMASK_X (U, D, L, R)**<br>**PCMP**|
|||0, 1, 1, 1<br>1|
|||1, 0, 1, 1<br>1|
|||1, 1, 0, 1<br>1|
|||1, 1, 1, 0<br>1|
|||0, 1, 0, 1<br>1|
|||1, 0, 1, 0<br>1|
|||All Others<br>0|
|SAI|4|Sleep After Interrupt. When enabled, the device will automatically enter low power mode<br>when the INT pin is asserted and the state machine has progressed to the SAI decision block.<br>Normal operation is resumed when INTpin is cleared over I2C.|
|PMASK_U|3|ProximityMask UP Enable. Writinga 1 disables thisphotodiode.|
|PMASK_D|2|ProximityMask LEFT Enable. Writinga 1 disables thisphotodiode.|
|PMASK_L|1|ProximityMask LEFT Enable. Writinga 1 disables thisphotodiode.|
|PMASK_R|0|ProximityMask RIGHT Enable. Writinga 1 disables thisphotodiode.|



### **Gesture Proximity Enter Threshold Register (0xA0)** 

The Gesture Proximity Enter Threshold Register value is compared with Proximity value, PDATA, to determine if the gesture state machine is entered. The proximity persistence filter, PPERS, is not used to determine gesture state machine entry. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|GPENTH|7:0|Gesture Proximity Entry Threshold. This register sets the Proximity threshold value used to|
|||determine a “gesture start” and subsequent entryinto thegesture state machine.|



### **Gesture Exit Threshold Register (0xA1)** 

The Gesture Proximity Exit Threshold Register value compares all non-masked gesture detection photodiodes (UDLR). Gesture state machine exit is also governed by the value in the Gesture Exit Persistence register, GEPERS. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|GEXTH|7:0|Gesture Exit Threshold. This register sets the threshold value used to determine a “gesture end”|
|||and subsequent exit of the gesture state machine. Setting GTHR_OUT to 0x00 will prevent|
|||gesture exit until GMODE is set to 0.|



### **Gesture Configuration One Register (0xA2)** 

The Gesture Configuration One Register contains settings that govern gesture detector masking, FIFO interrupt generation and gesture exit persistence filter. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|GFIFOTH|7:6|Gesture FIFO<br>datasets) tog|Threshold. This value is compared with the FIFO Level (i.e. the number of UDLR<br>enerate an interrupt (if enabled).|
|||**FIELD VALUE**|**THRESHOLD**|
|||0|Interrupt isgenerated after 1 dataset is added to FIFO|
|||1|Interrupt isgenerated after 4 datasets are added to FIFO|
|||2|Interrupt isgenerated after 8 datasets are added to FIFO|
|||3|Interrupt isgenerated after 16 datasets are added to FIFO|
|GEXMSK|5:2|Gesture Exit M<br>to determine<br>UDLR data wil<br>detectors.|ask. Controls which of the gesture detector photodiodes (UDLR) will be included<br>a “gesture end” and subsequent exit of the gesture state machine. Unmasked<br>l be compared with the value in GTHR_OUT. Field value bits correspond to UDLR|
|||**FIELD VALUE**|**EXIT MASK**|
|||0000|All UDLR detector data will be included in sum|
|||0001|R detector data will not be included in sum|
|||0010|L detector data will not be included in sum|
|||0100|D detector data will not be included in sum|
|||1000|U detector data will not be included in sum|
|||0101|…|
|||0110|L and D detector data will not be included in sum|
|||1111|All UDLR detector data will not be included in sum|
|GEXPERS|1:0|Gesture Exit P<br>equal orgreat|ersistence. When a number of consecutive “gesture end” occurrences become<br>er to the GEPERS value, the Gesture state machine is exited.|
|||**FIELD VALUE**|**PERSISTENCE**|
|||0|1st 'gesture end' occurrence results ingesture state machine exit.|
|||1|2nd 'gesture end' occurrence results ingesture state machine exit.|
|||2|4th 'gesture end' occurrence results ingesture state machine exit.|
|||3|7th 'gesture end' occurrence results ingesture state machine exit.|



### **Gesture Configuration Two Register (0xA3)** 

The Gesture Configuration Two register contains settings that govern wait time, LDR drive current strength and Gesture gain control. The GWTIME controls the amount of time in a low power mode between gesture detection cycles. GPDRIVE sets the LDR drive current strength governing LED intensity. GGAIN sets the analog gain associated with the photodiode output. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|RESERVED|7|Reserved. Writ|e as 0.|
|GGAIN|6:5|Gesture Gain|Control. Sets thegain of theproximityreceiver ingesture mode.|
|||**FIELD VALUE**|**GAIN VALUE**|
|||0|1x|
|||1|2x|
|||2|4x|
|||3|8x|
|GLDRIVE|4:3|Gesture LED D|rive Strength. Sets LED Drive Strength ingesture mode.|
|||**FIELD VALUE**|**LED CURRENT**|
|||0|100 mA|
|||1|50 mA|
|||2|25 mA|
|||3|12.5 mA|
|GWTIME|2:0|Gesture Wait T<br>gesture detec|ime. The GWTIME controls the amount of time in a low power mode between<br>tion cycles.|
|||**FIELD VALUE**|**WAIT TIME**|
|||0|0 ms|
|||1|2.8 ms|
|||2|5.6 ms|
|||3|8.4 ms|
|||4|14.0 ms|
|||5|22.4 ms|
|||6|30.8 ms|
|||7|39.2 ms|



Notes: 

1. The wait time register should be configured before GEN is asserted. 

2. The time described by GTIME is the actual signal integration time. The LED will be activated slightly longer (typically 1.33 μs) than the integration time. 

### **Gesture UP Offset Register (0xA4)** 

The GOFFSET_U is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|GOFFSET_U<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Gesture DOWN Offset Register (0xA5)** 

The GOFFSET_D is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|GOFFSET_D<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Gesture LEFT Offset Register (0xA7)** 

The GOFFSET_L is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|GOFFSET_L<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Gesture RIGHT Offset Register (0xA9)** 

The GOFFSET_R is an 8-bit value used to scale an internal offset correction factor to compensate for crosstalk in the application. This value is encoded in sign/magnitude format. 

|**Field**<br>**Bits**|**Description**||
|---|---|---|
|GOFFSET_L<br>7:0|**FIELD VALUE**|**Offset Correction Factor**|
||01111111|127|
||…|…|
||00000001|1|
||00000000|0|
||10000001|-1|
||…|…|
||11111111|-127|



### **Gesture Pulse Count and Length Register (0xA6)** 

The Gesture Pulse Count Register sets Pulse Width Modified current during a Gesture Pulse. The Gesture pulse count register bits set the number of pulses to be output on the LDR pin. The Gesture Length register bits set the amount of time the LDR pin is sinking current during a gesture pulse. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|GPLEN|7:6|Gesture Pulse|Length. Sets the LED_ONpulse width duringa Gesture LDR Pulse.|
|||**FIELD VALUE**|**PULSE LENGTH**|
|||0|4μs|
|||1|8μs (default)|
|||2|16μs|
|||3|32μs|
|GPULSE|5:0|Number of G  i<br>Number ofpu|esture Pulses. Specifies the number of pulses to be generated on LDR.<br>lses is set byGPULSE valueplus 1.|
|||**FIELD VALUE**|**Number OF PULSES**|
|||0|1|
|||1|2|
|||2|3|
|||…|…|
|||63|64|



Note: 

1. The Gesture Pulse Count Register resets to 0x40 at initial power up (POR). 

### **Gesture Configuration Three Register (0xAA)** 

The Gesture Configuration Three Register contains settings that govern which gesture photodiode pair: UP-DOWN and/ or RIGHT-LEFT will be enabled (have valid data in FIFO) while the gesture state machine is collecting directional data. Normal mode enables all four gesture photodiodes and places data into FIFO as expected. Disabling a photodiode pair, essentially allows the enabled pair to collect data twice as fast. Data stored in the FIFO for a disabled pair is not valid. This feature is useful to improve reliability and accuracy of gesture detection when only one-dimensional gestures are expected. 

|**Field**|**Bits**|**Description**||
|---|---|---|---|
|RESERVED|7:2|Reserved. Wri|te as 0.|
|GDIMS|1:0|Gesture Dime<br>results during|nsion Select. Selects which gesture photodiode pairs are enabled to gather<br> gesture.|
|||**FIELD VALUE**|**GESTURE DIRECTION**|
|||0|Bothpairs are active. UP-DOWN and LEFT-RIGHT FIFO data is valid.|
|||1|Onlythe UP-DOWNpair is active. Ignore LEFT-RIGHT data in FIFO.|
|||2|Onlythe LEFT-RIGHTpair is active. Ignore UP-DOWN data in FIFO.|
|||3|Bothpairs are active. UP-DOWN and LEFT-RIGHT FIFO data is valid.|



### **Gesture Configuration Four Register (0xAB)** 

The Gesture Configuration Four Register contains settings that govern Gesture interrupts and interrupt  clearing/reset as well as operation mode control and status. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|RESERVED|7:2|Reserved. Write as 0.|
|GIEN|1|Gesture interrupt enable. Gesture Interrupt Enable. When asserted, all gesture related<br>interrupts are unmasked.|
|GMODE|0|Gesture Mode. Reading this bit reports if the gesture state machine is actively running, 1<br>= Gesture, 0= ALS, Proximity, Color. Writing a 1 to this bit causes immediate entry in to the<br>gesture state machine (as if GPENTH had been exceeded). Writing a 0 to this bit causes exit of<br>gesture when current analogconversion has finished (as if GEXTH had been exceeded).|



### **Gesture FIFO Level Register (0xAE)** 

The GFLVL Register indicates the number of datasets that are currently available in the FIFO for read. Reading a complete FIFO dataset (from address 0xFC to 0xFF) constitutes the reduction of the GPENTH register by one. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|GFLVL|7:0|Gesture FIFO Level. This register indicates how many four byte data points - UDLR are ready for|
|||read over I2C. One four-byte dataset is equivalent to a single count in GFLVL.|



### **Gesture Status Register (0xAF)** 

The GSTATUS Register indicates the operational condition of the gesture state machine. 

|**Field**|**Bits**|**Description**|
|---|---|---|
|RESERVED|7:2|Do not care.|
|GFOV|1|Gesture FIFO Overflow. A setting of 1 indicates that the FIFO has filled to capacity and that new<br>gesture detector data has been lost.|
|GVALID|0|Gesture FIFO Data. GVALID bit is sent when GFLVL becomes greater than GFIFOTH (i.e. FIFO has<br>enough data to set GINT). GFIFOD is reset when GMODE = 0 and the GFLVL=0 (i.e. All FIFO data<br>has been read).|



Note: If GINT (irrespective of GVALID) remains set after the FIFO has been read GFLVL times, this indicates that new data has been added to FIFO during the last FIFO read. 

### **Clear Interrupt Registers (0xE4 – 0xE7)** 

Interrupts are cleared by “address accessing” the appropriate register. This is special I2C transaction consisting of only two bytes: chip address with R/W = 0, followed by a register address. 

|**Registers**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|IFORCE|0xE4|7:0|Forces an interrupt (anyvalue)|
|PICLEAR|0xE5|7:0|Proximityinterrupt clear (anyvalue)|
|CICLEAR|0xE6|7:0|ALS interrupt clear (anyvalue)|
|AICLEAR|0xE7|7:0|Clears all non-gesture interrupts (anyvalue)|



### **Gesture FIFO Register (0xFC – 0xFF)** 

In Gesture mode, the RAM area is repurposed as a 32 x 4 byte FIFO. Data is stored in four byte blocks. Each block, called a dataset, contains one integration cycle of UP, DOWN, LEFT, & RIGHT gesture data. Thirty-two separate datasets are stored within the FIFO before wrap-around overflow. If the FIFO overflows (i.e. 33 datasets before host/system can empty FIFO) new datasets will not replace existing datasets; instead an overflow flag will be set and new data will be lost. 

Host/Systems acquire gesture data by reading addresses: 0xFC, 0xFD, 0xFE, & 0xFF, which directly correspond to UP, DOWN, LEFT, & RIGHT data points. Data can be read a single byte at a time (four consecutive I2C transactions) or by using a page read. 

The internal FIFO read pointer and the FIFO Level register, GFLVL, values are updated when address 0xFF is accessed (single byte transactions) or when every fourth byte, corresponding to address 0xFF, is accessed in in page mode. If the FIFO continues to be accessed after GFLVL register is zero, dataset will be read as zero values. 

The recommended procedure for reading data stored in the FIFO begins when a gesture interrupt is generated (GFLVL > GFIFOTH). Next, the host reads the FIFO Level register, GFLVL, to determine the amount of valid data in the FIFO. 

Finally, the host begins to read address 0xFC (page read), and continues to read (clock-out data) until the FIFO is empty (Number of bytes is 4X GFLVL). For example, if GFLVL = 2, then the host should initiate a read at address 0xFC, and sequentially read all eight bytes. As the four-byte blocks are read, GFLVL register is decremented and the internal FIFO pointers are updated. 

|**Field**|**Address**|**Bits**|**Description**|
|---|---|---|---|
|GFIFO_U|0xFC|7:0|Gesture FIFO UP value.|
|GFIFO_D|0xFD|7:0|Gesture FIFO DOWN value.|
|GFIFO_L|0xFE|7:0|Gesture FIFO LEFT value.|
|GFIFO_R|0xFF|7:0|Gesture FIFO RIGHT value.|



### **Application Information Hardware** 

In a proximity sensing system, the internal IR LED can be pulsed by more than 100mA of rapidly switching current, therefore, a few design considerations must be kept in mind to get the best performance. The key goal is to reduce the power supply noise coupled back into the device during the LED pulses. 

In many systems, there is a quiet analog supply and a noisy digital supply. By connecting the quiet supply to the VDD pin and the noisy supply to the LED, the key goal can be meet. Place a 1-μF low-ESR decoupling capacitor as close as possible to the VDD pin and another at the LEDA pin, along with a bulk storage capacitor (≥ 10μF) at the output of the LED voltage regulator to supply the current surge. 

If operating from a single supply, use a 22-Ω resistor in series with the VDD supply line and a 1-μF low ESR capacitor to filter any power supply noise. The previous capacitor placement considerations apply. However note that where LED current is boosted beyond 100mA, it is recommended that the LEDA pin be connected to a separate power supply. 

VBUS in the above figures refers to the I²C bus voltage which is either VDD or 1.8 V.  The I²C signals and the Interrupt are open-drain outputs and require pull−up resistors. The pull-up resistor (RP) value is a function of the I²C bus speed, the I²C bus voltage, and the capacitive load. A 10-kΩ pull-up resistor (RPI) can be used for the interrupt line. 



<!-- Start of picture text -->
V BUS<br>Voltage LEDK<br>V DD<br>Regulator<br>1   µ F LDR R P R P R PI<br>C*<br>GND APDS-9960 INT<br>SCL<br>Voltage<br>Regulator LEDA SDA<br>≥  10  µ F 1   µ F<br><!-- End of picture text -->

*** Cap Value Per Regulator Manufacturer Recommendation** 

**Figure 14a. Circuit Implementation using Separate Power Supplies** 



<!-- Start of picture text -->
V BUS<br>22  Ω<br>Voltage LEDK<br>V DD<br>Regulator<br>≥  10  µ F 1   µ F LDR R P R P R PI<br>GND APDS-9960 INT<br>SCL<br>LEDA<br>SDA<br>1   µ F<br><!-- End of picture text -->

**Figure 14b. Circuit Implementation using Single Power Supply** 

### **Package Outline Dimensions** 



<!-- Start of picture text -->
0.60±0.08<br>(X8)<br>RECIEVER<br>8 1<br>1 8<br>7 2<br>Ø 1.10±0.05 2 7<br>2.70±0.05 3.94±0.20 3.73±0.10<br>6 3 (0.41) 3 6<br>Ø 0.90±0.05 (1.15) (X6)<br>IR EMITTER<br>5 4 4 5<br>1.18±0.05 0 .54±0.05 0.05 (0.80) 0 .05<br>2.36±0.20 PINOUT 0.60±0.08<br>1 - SDA (X8)<br>2 - INT<br>3 - LDR<br>4 - LEDK<br>1.35 ±0.20<br>5 - LEDA<br>6 - GND<br>7 - SCL<br>8 - VDD<br>2.10±0.10<br><!-- End of picture text -->

### **PCB Pad Layout** 

Suggested PCB pad layout guidelines for the Dual Flat No-Lead surface mount package are shown as follows: 



<!-- Start of picture text -->
0.60 0.60<br>0.80<br>0.25 (×6)<br>0.72 (×8)<br><!-- End of picture text -->

Note:   All linear dimensions are in mm. 

### **Tape Dimensions** 



<!-- Start of picture text -->
4 ±0.10<br>2 ±0.05 0.29 ±0.02<br>B0<br>€)- €D- -B-|-€D- -P- -€)- -€P- -B- -€P- -P- -€B- -€H- -- -B of<br>A A<br>6° Max<br>\8-4 8 ±0.10 8 Unit Orientation o aA | 1.70 ±0.10 ir<br>K0<br>2.70 ±0.10 \ 8° Max<br>A0<br>Note:   All linear dimensions are in mm.<br>Ø 1.50 ±0.10<br>Ø 1 ±0.05<br>1.75 ±0.10<br>4.30 ±0.10<br> +0.3012-0.10<br>5.50 ±0.05<br><!-- End of picture text -->

### **Reel Dimensions** 



<!-- Start of picture text -->
Lotus<br><!-- End of picture text -->

### **Moisture Proof Packaging** 

All APDS-9960 options are shipped in moisture proof package. Once opened, moisture absorption begins.  This part is compliant to JEDEC MSL 3. 



<!-- Start of picture text -->
Units in A Sealed<br>Mositure-Proof<br>Package<br>Package Is<br>Opened (Unsealed)<br>Environment<br>less than 30 deg C, and<br>less than 60% RH?<br>Yes<br>Package Is<br>No Baking Yes Opened less<br>Is Necessary  than 168 hours?<br>No<br>Perform Recommended No<br>Baking Conditions<br><!-- End of picture text -->

#### **Baking Conditions** 

|**Package**|**Temperature**|**Time**|
|---|---|---|
|In Reel|60 °C|48 hours|
|In Bulk|100 °C|4 hours|



#### **Recommended Storage Conditions** 

|**Storage Temperature**|10 °C to 30 °C|
|---|---|
|**Relative Humidity**|below 60% RH|



#### **Time from unsealing to soldering** 

If the parts are not stored in dry conditions, they must be baked before reflow to prevent damage to the parts. 

Baking should only be done once. 

After removal from the bag, the parts should be soldered within 168 hours if stored at the recommended storage conditions. If times longer than 168 hours are needed, the parts must be stored in a dry box. 

### **Recommended Reflow Profile** 



<!-- Start of picture text -->
MAX 260° C<br>255<br>R3 R4<br>230<br>217<br>200<br>R2<br>180<br>60 sec to 120 sec<br>150 Above 217° C<br>R5<br>120<br>R1<br>80<br>25<br>0 50 100 150 200 250 300<br>P1 P2 P3 P4 t-TIME<br>HEAT UP SOLDER PASTE DRY SOLDER COOL  (SECONDS)<br>REFLOW DOWN<br>Maximum  ∆ T/ ∆ time<br>Process Zone Symbol ∆ T or Duration<br>Heat Up P1, R1 25  ° C to 150  ° C 3  ° C/s<br>Solder Paste Dry P2, R2 150  ° C to 200  ° C 100 s to 180 s<br>Solder Reflow P3, R3 200  ° C to 260  ° C 3  ° C/s<br>P3, R4 260  ° C to 200  ° C -6  ° C/s<br>Cool Down P4, R5 200  ° C to 25  ° C -6  ° C/s<br>Time maintained above liquidus point , 217  ° C > 217  ° C 60 s to 120 s<br>Peak Temperature 260  ° C –<br>Time within 5  ° C of actual Peak Temperature > 255  ° C 20 s to 40 s<br>Time 25  ° C to Peak Temperature 25  ° C to 260  ° C 8 mins<br>TEMPERATURE (°C)<br><!-- End of picture text -->

The reflow profile is a straight-line representation of a nominal temperature profile for a convective reflow solder process. The temperature profile is divided into four process zones, each with different ∆ T/ ∆ time temperature change rates or duration. The ∆ T/ ∆ time rates or duration are detailed in the above table. The temperatures are measured at the component to printed circuit board connections. 

In process zone P1, the PC board and component pins are heated to a temperature of 150 ° C to activate the flux in the solder paste. The temperature ramp up rate, R1, is limited to 3 ° C per second to allow for even heating of both the PC board and component pins. 

Process zone P2 should be of sufficient time duration (100 to 180 seconds) to dry the solder paste. The temperature is raised to a level just below the liquidus point of the solder. Process zone P3 is the solder reflow zone. In zone P3, the temperature is quickly raised above the liquidus point of 

solder to 260 ° C (500 ° F) for optimum results. The dwell time above the liquidus point of solder should be between 60 and 120 seconds. This is to assure proper coalescing of the solder paste into liquid solder and the formation of good solder connections. Beyond the recommended dwell time the intermetallic growth within the solder connections becomes excessive, resulting in the formation of weak and unreliable connections. The temperature is then rapidly reduced to a point below the solidus temperature of the solder to allow the solder within the connections to freeze solid. 

Process zone P4 is the cool down after solder freeze. The cool down rate, R5, from the liquidus point of the solder to 25 ° C (77 °F) should not exceed 6 ° C per second maximum. This limitation is necessary to allow the PC board and component pins to change dimensions evenly, putting minimal stresses on the component. 

It is recommended to perform reflow soldering no more than twice. 

For product information and a complete list of distributors, please go to our web site: **www.avagotech.com** 

Avago, Avago Technologies, and the A logo are trademarks of Avago Technologies in the United States and other countries. Data subject to change.  Copyright © 2005-2013 Avago Technologies. All rights reserved. AV02-4191EN  -  November 8, 2013 

