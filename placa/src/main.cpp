#include <Arduino.h>
// Import libraries (BLEPeripheral depends on SPI)
#include <SPI.h>
#include <BLEPeripheral.h>

//custom boards may override default pin definitions with BLEPeripheral(PIN_REQ, PIN_RDY, PIN_RST)
BLEPeripheral blePeripheral = BLEPeripheral();

// create service
BLEService Service = BLEService("700A");

// create switch characteristic
// BLECharCharacteristic changedCharacteristic = BLECharCharacteristic("19b10000e8f2537e4f6cd104768aabcd", BLERead | BLEWrite);

// create switch characteristic only read
BLECharCharacteristic changedCharacteristic = BLECharCharacteristic("701A", BLERead);

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
  blePeripheral.addAttribute(changedCharacteristic);

  changedCharacteristic.setValue(0);
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

     if(value < 10){
      Serial.print(value);
      changedCharacteristic.setValue(value);
      value = value + 1;
      delay(5000);
     }
      
    }

    // central disconnected
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
} 