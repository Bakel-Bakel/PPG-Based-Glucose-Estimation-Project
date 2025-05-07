import time
import board
import busio
import adafruit_ssd1306
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from PIL import Image, ImageDraw

# I2C setup
i2c = busio.I2C(board.SCL, board.SDA)

# OLED setup (128x64)
oled = adafruit_ssd1306.SSD1306_I2C(128, 64, i2c, addr=0x3c)
oled.fill(0)
oled.show()

# ADS1015 setup
ads = ADS.ADS1015(i2c)
chan = AnalogIn(ads, ADS.P0)

# Create image buffer
image = Image.new("1", (128, 64))
draw = ImageDraw.Draw(image)

# Create buffer to store previous points
buffer = [0] * 128

while True:
    # Shift buffer to left
    buffer.pop(0)
    
    # Get new sample and scale it to fit the OLED height
    voltage = chan.voltage
    y = 64 - int((voltage / 3.3) * 64)  # Assuming 3.3V max

    # Append new y value
    buffer.append(y)

    # Clear the image
    draw.rectangle((0, 0, 128, 64), outline=0, fill=0)

    # Draw the waveform
    for x in range(1, 128):
        draw.line((x - 1, buffer[x - 1], x, buffer[x]), fill=255)

    # Display image
    oled.image(image)
    oled.show()

    time.sleep(0.05)
