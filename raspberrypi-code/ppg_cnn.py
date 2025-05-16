import time
import board
import busio
import adafruit_ssd1306
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from PIL import Image, ImageDraw
from gpiozero import LED
import numpy as np
import tflite_runtime.interpreter as tflite
from sklearn.preprocessing import MinMaxScaler
from gpiozero import Button
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


# === SWITCH SETUP ===
start_switch = Button(17)  # GPIO17, using internal pull-up by default


# === GPIOZERO LED SETUP ===
green_led = LED(9)     # GPIO9
yellow_led = LED(11)   # GPIO11
red_led = LED(10)      # GPIO10

def send_email(glucose_value):
    # --- Diagnosis logic ---
    if glucose_value < 100:
        diagnosis = "Healthy"
    elif glucose_value < 126:
        diagnosis = "Pre-Diabetic"
    else:
        diagnosis = "Diabetic"

    # --- Email setup ---
    sender_email = "Almahfouzm@gmail.com"
    recipients = ["Almahfouzm@gmail.com", "begededum4bakel@gmail.com", "elect.noura@gmail.com"]
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
    msg['To'] = ", ".join(recipients)  # Visible list in email header
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP_SSL("smtp.gmail.com", 465)
        server.login(sender_email, app_password)
        server.sendmail(sender_email, recipients, msg.as_string())
        server.quit()
        print("📧 Email sent successfully to multiple recipients.")
    except Exception as e:
        print(f"❌ Failed to send email: {e}")



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
run = True

# === MAIN LOOP ===
while run:
    print("Waiting for switch to start...")
    start_switch.wait_for_press()  # Block here until button is pressed
    print("Switch pressed! Starting PPG signal collection...")

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

    # === 3. PREDICT GLUCOSE ===
    input_data = norm_signal.astype(np.float32).reshape(1, 200, 1)
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    prediction = interpreter.get_tensor(output_details[0]['index'])[0][0] - 20
    print(f"Predicted Glucose: {prediction:.2f}")
    send_email(prediction)

    

    
    run = False

# === 4. LED CONTROL ===
light_led(prediction)
    
