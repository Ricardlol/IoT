#include <Arduino.h>
// Import libraries (BLEPeripheral depends on SPI)
#include <SPI.h>
#include <BLEPeripheral.h>
#include <string.h>

//custom boards may override default pin definitions with BLEPeripheral(PIN_REQ, PIN_RDY, PIN_RST)
BLEPeripheral blePeripheral = BLEPeripheral();

// create service
BLEService Service = BLEService("700A");

// create switch characteristic
// BLECharCharacteristic changedCharacteristic = BLECharCharacteristic("19b10000e8f2537e4f6cd104768aabcd", BLERead | BLEWrite);

// create switch characteristic only read
BLEIntCharacteristic glucose = BLEIntCharacteristic("701A", BLERead | BLENotify);
BLEIntCharacteristic heartbeat = BLEIntCharacteristic("702A", BLERead | BLENotify);
BLEIntCharacteristic pressure = BLEIntCharacteristic("703A", BLERead | BLENotify);
BLEIntCharacteristic oxygen_in_blood = BLEIntCharacteristic("704A", BLERead | BLENotify);

void setup() {
  Serial.begin(9600);
#if defined (__AVR_ATmega32U4__)
  delay(5000);  //5 seconds delay for enabling to see the start up comments on the serial board
#endif

  // set LED pin to output mode

  // set advertised local name and service UUID
  blePeripheral.setLocalName("Nordric Grup 7");
  blePeripheral.setAdvertisedServiceUuid(Service.uuid());

  // add service and characteristic
  blePeripheral.addAttribute(Service);
  // blePeripheral.addAttribute(changedCharacteristic);
  blePeripheral.addAttribute(glucose);
  blePeripheral.addAttribute(heartbeat);
  blePeripheral.addAttribute(pressure);
  blePeripheral.addAttribute(oxygen_in_blood);

  // changedCharacteristic.setValue(0);
  glucose.setValue(0);
  heartbeat.setValue(0);
  pressure.setValue(0);
  oxygen_in_blood.setValue(0);

  // begin initialization
  blePeripheral.begin();
  
  Serial.println(("Bluetooth device active, waiting for connections..."));
}

void loop() {
  BLECentral central = blePeripheral.central();
  
  if (central) {
    // central connected to peripheral
    Serial.print(F("Connected to central: "));
    Serial.println(central.address());
    byte value = 0;

    while (central.connected()) {
      // make a int value that is random between 80 and 130
      int glucoseValue = random(80, 130);
      // make a int value that is random between 60 and 100
      int heartbeatValue = random(60, 100);
      // make a int value that is random between 140 and 90
      int pressureValue = random(90, 140);
      // make a int value that is random between 95 and 100
      int oxygenInBloodValue = random(95, 100);


      // set the value of the characteristic
      Serial.print("Glucose: ");
      Serial.println(glucoseValue);
      Serial.print("Heartbeat: ");
      Serial.println(heartbeatValue);
      Serial.print("Pressure: ");
      Serial.println(pressureValue);
      Serial.print("Oxygen in blood: ");
      Serial.println(oxygenInBloodValue);


      glucose.setValue(glucoseValue);
      heartbeat.setValue(heartbeatValue);
      pressure.setValue(pressureValue);
      oxygen_in_blood.setValue(oxygenInBloodValue);
      // wait a little
      delay(1000);

    //  if(value < 10){
      // Serial.print(value);
      // changedCharacteristic.setValue(value);
      // value = value + 1;
      // delay(5000);
    //  }
      
    }

    // central disconnected
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
} 