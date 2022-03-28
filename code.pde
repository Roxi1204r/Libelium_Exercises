#include <WaspWIFI_PRO.h>
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>

uint8_t socket = SOCKET0;

char ESSID[] = "****";
char PASSW[] = "****";

char type[] = "http";
char host[] = "82.78.81.178";
char port[] = "80";

uint8_t error;
uint8_t status;
unsigned long previous;

char moteID[] = "roxi_libelium";

O2SensorClass O2Sensor(SOCKET_1);

#define POINT1_PERCENTAGE 0.0    
#define POINT2_PERCENTAGE 5.0  

#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0

float concentrations[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltages[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};

float temperature;  // Stores the temperature in ºC

void setup() 
{
  USB.ON();
  
  // 1. Switch ON the WiFi module
  if (WIFI_PRO.ON(socket) == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  // 2. Reset to default values
  if (WIFI_PRO.resetValues() == 0)
  {    
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }
  
  // 3. Set ESSID
  if (WIFI_PRO.setESSID(ESSID) == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }

  // 4. Set password key
  if (WIFI_PRO.setPassword(WPA2, PASSW) == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }

  // 5. Software Reset 
  if (WIFI_PRO.softReset() == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }

  RTC.ON();
  
  RTC.setTime("22:03:22:02:15:15:00");
  
  USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: "));
  USB.println(RTC.getTime());
  
  O2Sensor.setCalibrationPoints(voltages, concentrations);
  
  Gases.ON();  
  
  O2Sensor.ON();
  
  frame.setID(moteID);  
}

void loop()
{ 
  previous = millis();

  if (WIFI_PRO.isConnected() == true)
  {    
    USB.println(F("WiFi is connected OK"));

    frame.createFrame(ASCII); 

    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
    frame.addSensor(SENSOR_GASES_PRO_O2, O2Sensor.readConcentration());
    frame.addSensor(SENSOR_GASES_PRO_TC, Gases.getTemperature());

    frame.showFrame();  

    error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);

    if (error == 0)
    {
      USB.println(F("HTTP OK"));      
    }
    else
    {
      USB.println(F("Error calling 'getURL' function"));
      WIFI_PRO.printErrorCode();
    }
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
  }

  delay(3000); 
}