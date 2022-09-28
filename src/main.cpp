#include <Arduino.h>
#include <SPI.h>
#include <BLEPeripheral.h>

BLEPeripheral ledPeripheral = BLEPeripheral();

BLEService ledService = BLEService("19b10000e8f2537e4f6cd104768a1207");
BLECharCharacteristic ledCharacteristic = BLECharCharacteristic("19b10001e8f2537e4f6cd104768a1207", BLERead | BLEWrite);

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);

  ledPeripheral.setAdvertisedServiceUuid(ledService.uuid());
  ledPeripheral.addAttribute(ledService);
  ledPeripheral.addAttribute(ledCharacteristic);
  ledPeripheral.setLocalName("Nordic Grup 7");
  ledPeripheral.begin();
}

void loop()
{
  BLECentral central = ledPeripheral.central();

  if (central)
  {
    while (central.connected())
    {
      if (ledCharacteristic.written())
      {
        if (ledCharacteristic.value())
        {
          Serial.println("Connect");
          digitalWrite(LED_BUILTIN, HIGH);
        }
        else
        {
          Serial.println("Disconnect");
          digitalWrite(LED_BUILTIN, LOW);
        }
      }
    }
  }
}