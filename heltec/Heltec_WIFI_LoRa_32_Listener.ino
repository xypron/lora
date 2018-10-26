// SPDX-License-Identifier: GPL-2.0+
/*
 * Heltek WIFI LoRa 32 - packet listener
 *
 * Copyright (c) 2018 Heinrich Schuchardt <xypron.glpk@gmx.de>
 */

#include <SPI.h>
#include <LoRa.h>
#include <U8x8lib.h>

#define SX1278_SCK     5
#define SX1278_MISO   19
#define SX1278_MOSI   27
#define SX1278_SS     18
#define SX1278_RST    14
#define SX1278_DI0    26

#define I2C_CLOCK     15
#define I2C_DATA       4
#define I2C_RESET     16

/* LoRa frequency in MHz */
#define BAND     868.1E6

/* Five display lines */
#define BUFLEN (5 * 16)

/* Packet count */
static int pcnt;

U8X8_SSD1306_128X64_NONAME_SW_I2C
u8x8(I2C_CLOCK, I2C_DATA, I2C_RESET);

void setup()
{
  /* Initialize SPI */
  SPI.begin(SX1278_SCK, SX1278_MISO, SX1278_MOSI, SX1278_SS);

  /* Set LoRa pins */
  LoRa.setPins(SX1278_SS, SX1278_RST, SX1278_DI0);

  /* Initialize display */
  u8x8.begin();
  u8x8.setFont(u8x8_font_chroma48medium8_r);

  /* Write greeting */
  u8x8.drawString(0,0,"LoRa Listener");

  /* Initialize radio */
  if (!LoRa.begin(BAND)) {
    u8x8.drawString(0, 1, "Init failed");
    while (1);
  }
  LoRa.setSpreadingFactor(7);
  u8x8.drawString(0, 1, "initialized");
}

void loop()
{
  int packetSize = LoRa.parsePacket();
  char buf[BUFLEN + 1];
  int rssi;
  int i = 0;

  if (LoRa.parsePacket()) {

    /* Copy packet to buffer */
    i = 0;
    while (LoRa.available()) {
      if (i < BUFLEN) {
        buf[i++] = (char)LoRa.read();
      }
    }
    buf[i] = 0;

    /* Get Received Signal Strength Indicator */
    rssi = LoRa.packetRssi();

    /* Write to display */
    u8x8.clear();
    u8x8.drawString(0, 0, "LoRa Receiver");

    for (i = ((i - 1) >> 4) << 4; i >= 0; i -= 16) {
      u8x8.drawString(0, 2 + (i >> 4), buf + i);
      buf[i] = 0;
    }

    sprintf(buf, "Packet %d:", ++pcnt);
    u8x8.drawString(0, 1, buf);

    sprintf(buf, "RSSI: %d", rssi);
    u8x8.drawString(0, 7, buf);
  }
}
