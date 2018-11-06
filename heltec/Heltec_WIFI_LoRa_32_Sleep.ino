#include "SSD1306.h"

#define BUTTON_GREEN (1ULL << 32)
#define BUTTON_RED   (1ULL << 33)
#define BUTTON_BLUE  (1ULL << 39)

#define BUTTON_PIN_BITMASK \
  (BUTTON_GREEN | BUTTON_RED | BUTTON_BLUE)

#define SDA     4    // GPIO4  -- SX127x's SDA
#define SCL     15   // GPIO15 -- SX127X's SCL
#define RST_LED 16   // GPIO16 -- OLED reset pin
#define Vext    21

SSD1306 display(0x3c, SDA, SCL, RST_LED);

static void sendCommand(unsigned char command)
{
  Wire.beginTransmission(0x3C); // oled adress
  Wire.write(0x80); // command mode
  Wire.write(command);
  Wire.endTransmission();
}

void greeting(){
  esp_sleep_wakeup_cause_t wakeup_reason = esp_sleep_get_wakeup_cause();

  pinMode(Vext,OUTPUT);
  digitalWrite(Vext, LOW);    // set GPIO16 low to reset OLED
  delay(50); 
  display.init();
  display.flipScreenVertically();
  display.setTextAlignment(TEXT_ALIGN_LEFT);
  display.setFont(ArialMT_Plain_10);

  uint64_t mask = esp_sleep_get_ext1_wakeup_status();
  if (wakeup_reason == ESP_SLEEP_WAKEUP_EXT1) {

    if (mask & BUTTON_RED)
      display.drawString(0, 0, "Woken up by red button");
    else if (mask & BUTTON_GREEN)
      display.drawString(0, 0, "Woken up by green button");
    else if (mask & BUTTON_BLUE)
      display.drawString(0, 0, "Woken up by blue button");
  } else {
    display.drawString(0, 0, "Power on or reset");
  }
  display.display();
  delay(1000);
  sendCommand(0x8D); //into charger pump set mode
  sendCommand(0x10); //turn off charger pump
  sendCommand(0xAE); //set OLED sleep
}

void nap() {
  pinMode(32, INPUT);
  pinMode(33, INPUT);
  pinMode(39, INPUT);
  esp_sleep_enable_ext1_wakeup(BUTTON_PIN_BITMASK, ESP_EXT1_WAKEUP_ANY_HIGH);
  esp_sleep_pd_config(ESP_PD_DOMAIN_MAX, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_SLOW_MEM, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_OPTION_OFF);
  esp_deep_sleep_start();
}

void setup(){
  greeting();
  nap();
}

void loop(){
  /* Not reached */
}
