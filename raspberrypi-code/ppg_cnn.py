import time
import board
import busio
import adafruit_ssd1306
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from PIL import Image, ImageDraw
import RPi.GPIO as GPIO
import numpy as np
import tflite_runtime.interpreter as tflite
from sklearn.preprocessing import MinMaxScaler

# === GPIO SETUP ===
GREEN = 9  # GPIO11
YELLOW = 11  # GPIO11
RED = 10  # GPIO9

GPIO.setmode(GPIO.BCM)
GPIO.setup(GREEN, GPIO.OUT)
GPIO.setup(YELLOW, GPIO.OUT)
GPIO.setup(RED, GPIO.OUT)

def light_led(glucose):
    GPIO.output(GREEN, GPIO.LOW)
    GPIO.output(YELLOW, GPIO.LOW)
    GPIO.output(RED, GPIO.LOW)

    if glucose < 100:
        GPIO.output(GREEN, GPIO.HIGH)
    elif glucose < 126:
        GPIO.output(YELLOW, GPIO.HIGH)
    else:
        GPIO.output(RED, GPIO.HIGH)

# === I2C & OLED SETUP ===
i2c = busio.I2C(board.SCL, board.SDA)
oled = adafruit_ssd1306.SSD1306_I2C(128, 64, i2c, addr=0x3c)
oled.fill(0)
oled.show()

# === ADC SETUP ===
ads = ADS.ADS1015(i2c)
chan = AnalogIn(ads, ADS.P0)

# === OLED Drawing Buffer ===
image = Image.new("1", (128, 64))
draw = ImageDraw.Draw(image)
buffer = [0] * 128

# === LOAD TFLITE MODEL ===
interpreter = tflite.Interpreter(model_path="cnn_glucose_regressor.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# === MAIN LOOP ===
while True:
    # === 1. COLLECT 200 SAMPLES ===
    raw_signal = []
    for _ in range(200):
        voltage = chan.voltage
        raw_signal.append(voltage)
        y = 64 - int((voltage / 3.3) * 64)
        buffer.pop(0)
        buffer.append(y)

        draw.rectangle((0, 0, 128, 64), outline=0, fill=0)
        for x in range(1, 128):
            draw.line((x - 1, buffer[x - 1], x, buffer[x]), fill=255)
        oled.image(image)
        oled.show()
        time.sleep(0.05)

    # === 2. NORMALIZE SIGNAL ===
    scaler = MinMaxScaler()
    norm_signal = scaler.fit_transform(np.array(raw_signal).reshape(-1, 1)).flatten()

    # === 3. PREPARE INPUT FOR CNN ===
    input_data = norm_signal.astype(np.float32).reshape(1, 200, 1)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    prediction = interpreter.get_tensor(output_details[0]['index'])[0][0]
    print(f"Predicted Glucose: {prediction:.2f}")

    # === 4. LED CONTROL ===
    light_led(prediction)
