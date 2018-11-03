#include <SPI.h>
#include <LoRa.h>
#include <SSD1306.h>

// Pin definition of WIFI LoRa 32
#define SCK     5    // GPIO5  -- SX127x's SCK
#define MISO    19   // GPIO19 -- SX127x's MISO
#define MOSI    27   // GPIO27 -- SX127x's MOSI
#define SS      18   // GPIO18 -- SX127x's CS
#define RST     14   // GPIO14 -- SX127x's RESET
#define DI0     26   // GPIO26 -- SX127x's IRQ(Interrupt Request)
#define BAND    868.1E6

// Defintions for OLED
#define SDA     4    // GPIO4  -- SX127x's SDA
#define SCL     15   // GPIO15 -- SX127X's SCL
#define RST_LED 16   // GPIO16 -- OLED reset pin
#define Vext    21

// Definitions for LED
#define LED     25   // GPIO25 -- LED Light pin

SSD1306  display(0x3c, SDA, SCL, RST_LED);
int counter = 0;

void setup() {
  pinMode(Vext, OUTPUT);
  digitalWrite(Vext, LOW);    // set GPIO16 low to reset OLED
  delay(50);
  display.init();
  display.flipScreenVertically();
  display.setFont(ArialMT_Plain_10);
  delay(1500);

  // Enable output to LED
  pinMode(LED, OUTPUT);

  SPI.begin(SCK, MISO, MOSI, SS);
  LoRa.setPins(SS, RST, DI0);

  if (!LoRa.begin(BAND)) {
    while (1);
  }
}

void loop() {
  display.clear();
  display.setTextAlignment(TEXT_ALIGN_LEFT);
  display.setFont(ArialMT_Plain_10);
  display.drawString(0, 0, "Sending packet");
  display.drawString(0, 16, String(++counter));
  display.display();
  // send packet
  LoRa.beginPacket();
  LoRa.print("hello ");
  LoRa.print(counter);
  LoRa.endPacket();
  // blink
  digitalWrite(LED, HIGH);
  delay(100);
  digitalWrite(LED, LOW);
  delay(1900);
}
