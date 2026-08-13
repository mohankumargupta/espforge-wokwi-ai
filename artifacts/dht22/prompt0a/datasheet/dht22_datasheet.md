# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

## **Digital-output relative humidity & temperature sensor/module** 

## **DHT22 (DHT22 also named as AM2302)** 



Capacitive-type humidity and temperature module/sensor 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

1. Feature & Application: 

- Full range temperature compensated       * Relative humidity and temperature measurement 

- Calibrated digital signal     *Outstanding long-term stability   *Extra components not needed 

- Long transmission distance  * Low power consumption        *4 pins packaged and fully interchangeable 

### **2. Description:** 

DHT22 output calibrated digital signal. It utilizes exclusive digital-signal-collecting-technique and humidity sensing technology, assuring its reliability and stability.Its sensing elements is connected with 8-bit single-chip computer. 

Every sensor of this model is temperature compensated and calibrated in accurate calibration chamber and the calibration-coefficient is saved in type of programme in OTP memory, when the sensor is detecting, it will cite coefficient from memory. 

Small size & low consumption & long transmission distance(20m) enable DHT22 to be suited in all kinds of harsh application occasions. 

Single-row packaged with four pins, making the connection very convenient. 

### **3. Technical Specification:** 

|Model|DHT22|
|---|---|
|Power supply|3.3-6V DC|
|Output signal|digital signal via single-bus|
|Sensing element|Polymer capacitor|
|Operating range|humidity 0-100%RH;              temperature-40~80Celsius|
|Accuracy|humidity +-2%RH(Max +-5%RH);   temperature <+-0.5Celsius|
|Resolution or sensitivity|humidity 0.1%RH;                temperature 0.1Celsius|
|Repeatability|humidity+-1%RH;                temperature+-0.2Celsius|
|Humidity hysteresis|+-0.3%RH|
|Long-term Stability|+-0.5%RH/year|
|Sensing period|Average: 2s|
|Interchangeability|fully interchangeable|
|Dimensions|small size 14*18*5.5mm;          big size 22*28*5mm|



### **4. Dimensions: (unit----mm)** 

### **1) Small size dimensions: (unit----mm)** 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 



<!-- Start of picture text -->
15.1 /./<br>ee<br>| | |<br>35 ||l| |<br>ay -2.0<br>0.5<br><!-- End of picture text -->

**Pin sequence number:  1 2 3 4 (from left to right direction).** 

|**Pin**|**Function**|
|---|---|
|**1**|**VDD----power supply**|
|**2**|**DATA--signal**|
|**3**|**NULL**|
|**4**|**GND**|



# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

### **5. Electrical connection diagram:** 



<!-- Start of picture text -->
VDD<br>DHT22 1Ein<br>M te U [A 2Pin<br>4Pin<br>GND<br><!-- End of picture text -->

**3Pin---NC, AM2302**<sup>is another name for DHT22</sup> 

### **6. Operating specifications:** 

#### **(1) Power and Pins** 

Power's voltage should be 3.3-6V DC. When power is supplied to sensor, don't send any instruction to the sensor within one second to pass unstable status. One capacitor valued 100nF can be added between VDD and GND for wave filtering. 

#### **(2) Communication and signal** 

Single-bus data is used for communication between MCU and DHT22, it costs 5mS for single time communication. 

Data is comprised of integral and decimal part, the following is the formula for data. 

DHT22 send out higher data bit firstly! 

DATA=8 bit integral RH data+8 bit decimal RH data+8 bit integral T data+8 bit decimal T data+8 bit check-sum If the data transmission is right, check-sum should be the last 8 bit of "8 bit integral RH data+8 bit decimal RH data+8 bit integral T data+8 bit decimal T data". 

When MCU send start signal, DHT22 change from low-power-consumption-mode to running-mode. When MCU finishs sending the start signal, DHT22 will send response signal of 40-bit data that reflect the relative humidity 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

and temperature information to MCU. Without start signal from MCU, DHT22 will not give response signal to MCU. One start signal for one time's response data that reflect the relative humidity and temperature information from DHT22. DHT22 will change to low-power-consumption-mode when data collecting finish if it don't receive start signal from MCU again. 

1) Check bellow picture for overall communication process: 



<!-- Start of picture text -->
------------------------------------------------------------------------------------------------------------------------------------<br>   Host computer send out<br>          start signal.                                                  Data transmission finished,<br>                       Sensor send out                                  and RL pull up bus's voltage<br>                       response signal.       Output data: 1bit"0"               for next transmission<br>A<br>—| aees —| aes| atl o—| | Bc ay i |leeee REG S e *e<br>| | |<br>BBR | lgrase | | fraem | | | REE<br>| ol Ea ES a cou 50a<br>PRB:<br>— D><br>EUS DHTARS<br>        Pull up and wait            Host's signal     Sensor's signal         Output data: 1bit "1"<br>     response from sensor                                                           Sensor pull down<br>                  Pull up voltage and get                                              bus's voltage<br>                   ready for sensor's output.<br>Single-bus output<br>------------------------------------------------------------------------------------------------------------------------------------<br><!-- End of picture text -->

2) Step 1: MCU send out start signal to DHT22 

Data-bus's free status is high voltage level. When communication between MCU and DHT22 begin, program of MCU will transform data-bus's voltage level from high to low level and this process must beyond at least 1ms to ensure DHT22 could detect MCU's signal, then MCU will wait 20-40us for DHT22's response. 

Check bellow picture for step 1: 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 



<!-- Start of picture text -->
 Your specialist in innovating humidity & temperature sensors<br>-----------------------------------------------------------------------------------------------------------------------------------<br>            Host computer send start signal          Sensor send out response signal<br>           and keep this signal at least  1ms             and keep this signal 80us<br>                                 Host pull up voltage<br>                             -and wait sensor's response         Sensor pull up bus's voltage<br>| | Se | 80us<br>| —+ RR | i<br>Megagay yegeypoaeroceeraaa po FRG eR<br>i<br>&<br>HER | s pan MEMS<br>SRV:<br>LES DHTfA =<br>                             Signal from host                           Start data transmission<br>                                                   Signal from sensor<br>Single-bus signal<br><!-- End of picture text -->

Step 2: DHT22 send response signal to MCU 

When DHT22 detect the start signal, DHT22 will send out low-voltage-level signal and this signal last 80us as response signal, then program of DHT22 transform data-bus's voltage level from low to high level and last 80us for DHT22's preparation to send data. 

Check bellow picture for step 2: 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 



<!-- Start of picture text -->
                     Start transmit 1bit data                        Start transmit next bit data<br>                                      26-28us voltage-length means data "0"<br>| = 26us—28us be<br>| | |zeaRo |<br>VC C= Gai | mem Font<br>wey og |<br>SR: as Gna<br>ous DHT HS<br>                                  Host signal                   Sesnor's signal<br><!-- End of picture text -->

Single-bus signal 

Step 3: DHT22 send data to MCU 

When DHT22 is sending data to MCU, every bit's transmission begin with low-voltage-level that last 50us, the following high-voltage-level signal's length decide the bit is "1" or "0". 

Check bellow picture for step 3: 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 



<!-- Start of picture text -->
                                            70us voltage-length means 1bit data "1"<br>                   Start transmit 1bit data                             Start transmit next bit data<br>| | 70us —<br>| | fom" |<br>le<br>Ce ae LSttC(<is~=~=~S*s*t*~*<br>ee ee |<br>aida<br>Hee HTfs ><br>                               Host signal              Sesnor's signal<br><!-- End of picture text -->

Single-bus signal 

If signal from DHT22 is always high-voltage-level, it means DHT22 is not working properly, please check the electrical connection status. 

### **7. Electrical Characteristics:** 

|Item|Condition|Min|Typical|Max|Unit|
|---|---|---|---|---|---|
|Power supply|DC|3.3|5|6|V|
|Current supply|Measuring|1||1.5|mA|
||Stand-by|40|Null|50|uA|
|Collecting<br>period|Second||2||Second|



*Collecting period should be : >2 second. 

Thomas Liu (Business Manager) 

Email: thomasliu198518@yahoo.com.cn 

# **Aosong Electronics Co.,Ltd** 

Your specialist in innovating humidity & temperature sensors 

### **8. Attentions of application:** 

- (1) Operating and storage conditions 

We don't recommend the applying RH-range beyond the range stated in this specification. The DHT22 sensor can recover after working in non-normal operating condition to calibrated status, but will accelerate sensors' aging. 

- (2) Attentions to chemical materials 

Vapor  from chemical materials may interfere DHT22's sensitive-elements and debase DHT22's sensitivity. 

- (3) Disposal when (1) & (2) happens 

Step one: Keep the DHT22 sensor at condition of Temperature 50~60Celsius, humidity <10%RH for 2 hours; Step two: After step one, keep the DHT22 sensor at condition of Temperature 20~30Celsius, humidity >70%RH for 5 hours. 

- (4) Attention to temperature's affection 

Relative humidity strongly depend on temperature, that is why we use temperature compensation technology to ensure accurate measurement of RH. But it's still be much better to keep the sensor at same temperature when sensing. 

DHT22 should be mounted at the place as far as possible from parts that may cause change to temperature. 

- (5) Attentions to light 

Long time exposure to strong light and ultraviolet may debase DHT22's performance. 

- (6) Attentions to connection wires 

The connection wires' quality will effect communication's quality and distance, high quality shielding-wire is recommended. 

- (7) Other attentions 

- Welding temperature should be bellow 260Celsius. 

- Avoid using the sensor under dew condition. 

- Don't use this product in safety or emergency stop devices or any other occasion that failure of DHT22 may cause personal injury. 

Email: thomasliu198518@yahoo.com.cn 

