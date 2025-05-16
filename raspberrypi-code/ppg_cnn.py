import time
import board
import busio
import adafruit_ssd1306
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from PIL import Image, ImageDraw
from gpiozero import LED, Button
import numpy as np
import tflite_runtime.interpreter as tflite
from sklearn.preprocessing import MinMaxScaler
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from signal import pause

# === SWITCH SETUP ===
start_switch = Button(17)  # GPIO17, pull-up by default

# === LED SETUP ===
green_led = LED(9)
yellow_led = LED(11)
red_led = LED(10)

def send_email(glucose_value):
    if glucose_value < 100:
        diagnosis = "Healthy"
    elif glucose_value < 126:
        diagnosis = "Pre-Diabetic"
    else:
        diagnosis = "Diabetic"

    sender_email = "Almahfouzm@gmail.com"
    recipients = ["elect.noura@gmail.com", "Almahfouzm@gmail.com", "mahaalfaresii@gmail.com"]
    app_password = "wjwu japf rozh pflo"

    subject = "Glucose Prediction Result"
    body = f"""
    Glucose Prediction Report:
    ---------------------------
    Predicted Glucose Level: {glucose_value:.2f} mg/dL
    Diagnosis: {diagnosis}

    This message was sent automatically from your Raspberry Pi glucose monitor.
    """

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = ", ".join(recipients)
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP_SSL("smtp.gmail.com", 465)
        server.login(sender_email, app_password)
        server.sendmail(sender_email, recipients, msg.as_string())
        server.quit()
        print("Email sent successfully.")
    except Exception as e:
        print(f"Failed to send email: {e}")

def light_led(glucose):
    green_led.off()
    yellow_led.off()
    red_led.off()

    if glucose < 100:
        green_led.on()
    elif glucose < 126:
        yellow_led.on()
    else:
        red_led.on()

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

# === MAIN FUNCTION ===
def run_once():
    print("Switch pressed! Starting PPG signal collection...")

    # 1. COLLECT SIGNAL
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

    # 2. NORMALIZE & PREDICT
    scaler = MinMaxScaler()
    norm_signal = scaler.fit_transform(np.array(raw_signal).reshape(-1, 1)).flatten()
    input_data = norm_signal.astype(np.float32).reshape(1, 200, 1)
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    prediction = interpreter.get_tensor(output_details[0]['index'])[0][0] - 20

    print(f"Predicted Glucose: {prediction:.2f}")
    send_email(prediction)
    light_led(prediction)

    # 3. CLEAR
    oled.fill(0)
    oled.show()
    print("OLED display cleared after measurement.")

    

# === BIND THE BUTTON TO THE RUN FUNCTION ===
start_switch.when_pressed = run_once

print("System ready. Press the button to start measurement...")
pause()  # Keeps script running forever
